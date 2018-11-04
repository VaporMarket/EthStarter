pragma solidity ^0.4.24;

// EPM Library Usage
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Proxy.sol";


/** @title A managment contract to store and manage all Campains for the platform.
* This enables users to create new campagins and then other users can fund them.
* Users can only fund campains that are currently running(have started and not
* finished). If a user withdraws from a campaign, they can only do so if it does
* not result in the campaign no longer getting funded.
* @author Chris Maree - SoIdarity 
*/
contract CampaignManager is Ownable, Proxy{
    /** @dev store the current state of the Camaign. 
    */    
    
    /** @dev define the standard properties of a Campaign 
    * @notice the doners are a mapping of addresses to uints. This enables each
    * donar to donate more than one time and for a record to be kept. Moreover,
    * if a doner removes their donation, a negative value can be stored here to
    * indicate the withdrawl
    * @notice the donersAddresses is used to store an array of all donars that
    * contributed as maps are not itterable by populated keys
    */
    struct Campaign {
        address manager;
        uint startingTime;
        uint endingTime;
        uint balance;
        uint goal;
        mapping(address=>int[]) doners;
        address[] donersAddresses;
        string ipfsHash;
        uint presalePrice;
        uint postsalePrice;
    }
    
    /** @dev store the total number of campaigns. Useful for retreving all of them **/
    uint public campaignCount;
    
    /**
    * @dev Stop the creation of new campagins
    */
    bool public emergencyStop_stopCreation = false;
    
    /**
    * @dev stops the fundion of existing campagins
    */
    bool public emergencyStop_stopFunding = false;
    
    /** @dev store all campaigns as a mapping to their unique ID **/
    mapping(uint => Campaign) public campaigns;
    
    /**
    * @dev Verify the times spesified for the campaign are valid
    * @param _startingTime of the campaign (unix time stamp)
    * @param _endingTime of the campaign (unix time stamp)
    */
    modifier validNewCampaignTime(uint _startingTime,uint _endingTime){
        require(_startingTime >= now, "Firstly, Start time must be larger than the current time");
        require(_endingTime > _startingTime,"Secondly, the end time should be more than the starting time");
        _;
    }
    
    /**
    * @dev Verify the current time is past the start time of the camaign
    * @param _campaignID unique identifer of the campaign
    */
    modifier campaignHasStarted(uint _campaignID) {
        require(now > campaigns[_campaignID].startingTime, "Current time must be larger than starting time for project to start");
        _;
    }
    
    /**
    * @dev checks if the campaign is yet to start
    * @param _campaignID unique identifer of the campaign
    */
    modifier campaignNotStarted(uint _campaignID){
        require(now < campaigns[_campaignID].startingTime, "Current time should be less than the starting time");
        _;
    }

    /**
    * @dev checks if the campain has ended (current time more than end time)
    * @param _campaignID unique identifer of the campaign
    */
    modifier campaignEnded(uint _campaignID){
        require(now > campaigns[_campaignID].endingTime, "Current time must be bigger than the end time for the campaign to have ended");
        _;
    }

    /**
    * @dev Verify the current time is not past the end time of the camaign
    * @param _campaignID unique identifer of the campaign
    */
    modifier campaignHasNotEnded(uint _campaignID) {
        require(now < campaigns[_campaignID].endingTime, "Current time must be less than the end time for the campaign to have not ended");
        _;
    }
    
    /**
    * @dev checks if the campain has Succeeded (donation > than goal)
    * @param _campaignID unique identifer of the campaign
    */
    modifier campaignSucceeded(uint _campaignID){
        require(campaigns[_campaignID].balance > campaigns[_campaignID].goal, "The balance of the campaign must be more than the goal");
        _;
    }


    /**
    * @dev Verify that the donation will not cause the campaign to drop below
    * its goal. This prevents someone from making a campaign that would succeed,
    * fail due to cancelling their contribution
    * @notice value is required as the user has the choice to either cancle or
    * reduce their donation.
    * @param _campaignID unique identifer of the campaign
    * @param _value is the amount that the donar wants to reduce their donation by
    */
    modifier campaignWillNotDropBelowGoal(uint _campaignID, uint _value) {
        // We only need to do this check if the campaign has been funded thus far, with the balance being more than the goal
        if(campaigns[_campaignID].balance>campaigns[_campaignID].goal){
            require(
                campaigns[_campaignID].balance-_value > campaigns[_campaignID].goal,
                "The value of the campaign balance after the reduction will be more than the goal");
        }
        _;
    }
    
    /**
    * @dev Verify that the reduction from a donation will not cause the donation
    * to drop below zero, and as such enabling the user to take out more than
    * they deposited. Moreover, this check ensures that a user who did not donate
    * cant withdraw as this assert will fail as their total donation balance will
    * be zero.
    * @notice the function needs to check the total donation for the user by
    * summing over all previous donations
    * @param _campaignID unique identifer of the campaign
    * @param _value is the amount that the donar wants to reduce their donation by
    */
    modifier adequetDonationToReduce(uint _campaignID, uint _value){
        int totalDonation = 0;
        for (uint i = 0; i < campaigns[_campaignID].doners[msg.sender].length; i++){
            totalDonation += campaigns[_campaignID].doners[msg.sender][i];
        }
        require(
            totalDonation-int(_value) >= 0, 
            "The sum of all donations for a particular user should be more than 0 to enable any kind of donation reduction");
        _;
    }
    
    /**
    * @dev checks that the caller of the function is the campaign's manager;
    * This is the person that create the campaign.
    * @param _campaignID unique identifer of the campaign
    */
    modifier onlyManager(uint _campaignID){
        require(msg.sender == campaigns[_campaignID].manager,"The caller should be equal to the manager");
        _;
    }
    /**
    * @dev checks if a caller of the function is a Contributer to the campaign
    * @notice If they have contributed, there will be some items within the 
    * doners array representing donations.
    * @param _campaignID unique identifer of the campaign
    */
    modifier onlyContributer(uint _campaignID){
        require(campaigns[_campaignID].doners[msg.sender].length > 0,"The caller should have contributed at least once to the campaign");
        _;
    }
    
    /**
    * @dev Prevents the creation of new campaigns
    */
    modifier emergencyStop_Creation(){
        require(emergencyStop_stopCreation == false, "The emergency stop creation is active");
        _;
    }
    
    /**
    * @dev Prevents the funding of new campaigns
    */
    modifier emergencyStop_Funding(){
        require(emergencyStop_stopFunding == false, "The emergency stop funding is active");
        _;
    }

    /**
    * @dev Checks funding value
    */
    modifier validPrice(uint _campaignID){
        if (campaigns[_campaignID].balance <= campaigns[_campaignID].goal) {
            require(msg.value >= campaigns[_campaignID].presalePrice, "The value needs to exceed the presale price");
        } else if (campaigns[_campaignID].balance >= campaigns[_campaignID].goal) {
            require(msg.value >= campaigns[_campaignID].postsalePrice, "The value needs to exceed the postsale price");
        } else if (campaigns[_campaignID].endingTime >= now) {
            require(msg.value >= campaigns[_campaignID].postsalePrice, "The value needs to exceed the postsale price");
        }
        _;
    }

    /**
    * @dev Checks whether the presale is over
    */
    modifier PresaleOver(uint _campaignID){
        require(campaigns[_campaignID].balance >= campaigns[_campaignID].goal || now > campaigns[_campaignID].endingTime, "Presale still in session");
        _;
    }
    
     /** @dev Assign owner and reset campaign */
    constructor() 
        public {
        owner = msg.sender;
        campaignCount = 0;
    }
    
    function enableEmergencyStop_Creation()
        public
        onlyOwner
    {
        emergencyStop_stopCreation = true;
    }
    
    function enableEmergencyStop_Funding()
        public
        onlyOwner
    {
        emergencyStop_stopFunding = true;
    }
    
    /**
    * @dev Generate a new campaign struct and store it. Assign manager and values
    * @notice this sets the inital value of the State to NotStarted
    * @param _startingTime unix time stamp of when the campaign will start
    * @param _endingTime unix time stamp of when the campaign will end
    * @param _goal value of the campaign (in ETH).
    * @param _ipfsHash represents the campain information on IPFS in a hash
    */
    function createCampaign(
        uint _startingTime, 
        uint _endingTime, 
        uint _goal, 
        string _ipfsHash,
        uint _presalePrice,
        uint _postsalePrice
    ) 
        public
        validNewCampaignTime(_startingTime,_endingTime)
        emergencyStop_Creation
        returns(uint)
    {
        address[] memory emptydonersAddresses;
        campaigns[campaignCount] = Campaign({
            manager: msg.sender,
            startingTime: _startingTime,
            endingTime: _endingTime,
            balance: 0,
            goal: _goal,
            donersAddresses: emptydonersAddresses,
            ipfsHash: _ipfsHash,
            presalePrice: _presalePrice,
            postsalePrice: _postsalePrice
        });
        campaignCount += 1;
        return campaignCount;
    }
    
    /**
    * @dev Enable anyone to donate to a campaign. The campaign must have started,
    * have not finished.
    * @notice this changes the state of a campaign from NotStarted -> Running
    * @param _campaignID unique identifer of the campaign
    */
    function fundCampaign(uint _campaignID) 
        public
        payable
        campaignHasStarted(_campaignID)
        validPrice(_campaignID)
        emergencyStop_Funding
    {
        campaigns[_campaignID].balance += msg.value;
        // Need to implicity typecast the msg.value for as donars can be
        // negative when withdrawing
        campaigns[_campaignID].doners[msg.sender].push(int(msg.value));
        // There is no point in storing a doners address multiple times in the
        //donersAddresses array so only add if you this is your first contribution
        // if(campaigns[_campaignID].doners[msg.sender].length==0){
        campaigns[_campaignID].donersAddresses.push(msg.sender);         
        // }
    }
    
    /**
    * @dev Enable any donar to reduce their donation. The campaign must have,
    * started have not finished and their reduction must not make a project that
    * would succeed fail due to the reduction.
    * @notice we dont need to check the state of the campain as you would only
    * call this function if you had at some point donated and the check is done 
    * there (function fundCampaign).
    * @param _campaignID unique identifer of the campaign
    * @param _value the amount bywhich the campaign is reduced
    */
    function reduceDontation(uint _campaignID, uint _value)
        public
        campaignHasStarted(_campaignID)
        campaignHasNotEnded(_campaignID)
        campaignWillNotDropBelowGoal(_campaignID, _value)
        adequetDonationToReduce(_campaignID, _value)
    {
        campaigns[_campaignID].balance -= _value;
        // store the reduction in the doners respective array as a negative value
        // preserving a history of reductions. The sum of this array is their
        // respective donation
        campaigns[_campaignID].doners[msg.sender].push(-int(_value));
        msg.sender.transfer(_value); //refund the user for the Ether they sent in
    }
    
    /**
    * @dev Enable the campaign manager to withdraw the funds donated after the 
    * period is finished. The state of the campaign.state defines if the ownerc
    * @notice The campaign state changes from Running -> Funded
    * @param _campaignID unique identifer of the campaign
    */
    function withdrawCampaignFunds(uint _campaignID)
        public
        onlyManager(_campaignID)
        PresaleOver(_campaignID)
    {
        // Note that we dont have to change the balance of the campaign as we
        // prevent double withdraws by checking the state of the campaign. 
        // Leaving the balance within the campaign enables an easy way to sender
        // the total funds sent to the campaign.
        msg.sender.transfer(campaigns[_campaignID].balance);
    }

    /**
    * @dev Enables a fund manager to update the ipfs hash on an entry in the 
    * case they change it. 
    * @notice They can ONLY do this before a fund is sstarted.
    * @param _campaignID unique identifer of the campaign
    * @param _newHash defines the new IPFS hash for the campaign
    */
    function updateIpfsHash(uint _campaignID, string _newHash)
        public
        onlyManager(_campaignID)
        campaignNotStarted(_campaignID)
    {
        campaigns[_campaignID].ipfsHash = _newHash;
    }
    
    function fetchCampaign(uint _campaignID)
        public
        view
        returns
        (address manager,
        uint startingTime,
        uint endingTime,
        uint balance,
        uint goal,
        address[] donersAddresses,
        string ipfsHash,
        uint presalePrice,
        uint postsalePrice)
    {
        manager = campaigns[_campaignID].manager;
        startingTime = campaigns[_campaignID].startingTime;
        endingTime = campaigns[_campaignID].endingTime;
        balance = campaigns[_campaignID].balance;
        goal = campaigns[_campaignID].goal;
        donersAddresses = campaigns[_campaignID].donersAddresses;
        ipfsHash = campaigns[_campaignID].ipfsHash;
        presalePrice = campaigns[_campaignID].presalePrice;
        postsalePrice = campaigns[_campaignID].postsalePrice;
        return (manager, startingTime, endingTime, balance, goal, donersAddresses, ipfsHash, presalePrice, postsalePrice);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";


contract WavePortal is Ownable,Initializable {
    uint256 totalWaves;
    string public name;
    string public metadata;

    event NewWave(address indexed from, uint256 timestamp, string message);
    // event Initialized(address indexed _nftContract);
    event NewVote(uint256 index,address indexed from, uint256 weight, uint256 _type);

    
    mapping(uint256 => mapping(address => bool)) voters;
    mapping(uint256 => uint256) public up;
    mapping(uint256 => uint256) public down;
    address public nftContract=address(0);
    mapping(address => bool) moderators;

    struct Wave {
        address waver; 
        string message; 
        string metadata; 
        uint256 timestamp;
        uint256 deadline;
    }
    struct Vote {
        address voter; 
        uint256 weight;
        uint256  _type;
    }

    mapping(uint256 => Vote[]) public votes;
    Wave[] public waves;
    mapping(address => uint256) public lastWavedAt;

   constructor() payable {
        console.log("We have been constructed!");
    }

    modifier initialized {
      require(nftContract != address(0));
      _;
    }



    function initialize(bytes memory _data, address _owner) external initializer {
        // @imp make sure doesn't get initialized again
        // @imp only owners can access
       address _nftContract;
       string memory _name;
       string memory _metadata;
       (_nftContract, _name, _metadata) = dataDecoder(_data);
       nftContract=_nftContract;
        name=_name;
        metadata=_metadata;
    //    transferOwnership(_owner);
    //    emit Initialized(_nftContract);
    }

    function dataDecoder(bytes memory data)
        internal
        pure
        returns (
          address _nftContract,string memory _name,string memory _metadata
        )
    {
        (_nftContract, _name, _metadata) = abi.decode(
            data,
            (address, string, string)
        );
    }

    function setName(string memory _name) public  onlyOwner{
        name=_name;
    }
    function setMetadata(string memory _metadata) public  onlyOwner{
        metadata=_metadata;
    }

    function modifyModerators(address _moderator,bool _membership) public onlyOwner {
        moderators[_moderator]=_membership;
    }


    function wave(string memory _message,uint256 _deadline,string memory _metadata) public {
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );
        require(
            _deadline>block.timestamp,
            "Backdated"
        );

    totalWaves += 1;
    console.log("%s has waved!", msg.sender);

    waves.push(Wave(msg.sender, _message,_metadata, block.timestamp,_deadline));
    up[totalWaves]=0;
    down[totalWaves]=0;
    emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
    function getAllVotes(uint256 _index) public view returns (Vote[] memory) {
        return votes[_index];
    }

    function getTotalVotes(uint256 _index) public view returns (uint256) {
        return votes[_index].length;
    }

    function vote(uint256 _index,uint256  _type) public {
        require(
            waves[_index].deadline>block.timestamp,
            "Deadline Ended"
        );
        require(
            voters[_index][msg.sender]==false,
            "Already voted"
        );
        require(
            _type<2,
            "Invalid type"
        );
        uint256 balance=IERC721(nftContract).balanceOf(msg.sender);
        require(
            balance>0,
            "No Balance"
        );
        
        if(_type==0){
                up[_index]+=balance;
        } else if(_type==1){
                down[_index]+=balance;
        }
        Vote[] storage newVote=(votes[_index]);
        newVote.push(Vote(msg.sender,balance,_type));
        voters[_index][msg.sender]=true;
        emit NewVote(_index,msg.sender,balance,_type);
    }
}
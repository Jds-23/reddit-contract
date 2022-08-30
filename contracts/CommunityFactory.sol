// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract CommunityFactory is Ownable {
    uint256 public totalImplementation;
    address[] public implementationCommunityContract;
    uint256 public totalCommunities;
    address[] public communities;
    event ImplementationAdded(uint index,address _communityContract);
    event CommunityCreated(uint index,address clone);
    constructor()  { }
    function addCommunityImplementation(address _communityContract) onlyOwner public {
       require(_communityContract!=address(0));
       implementationCommunityContract.push(_communityContract);
       totalImplementation+=1;
       emit ImplementationAdded(totalImplementation,_communityContract);
    }
    function deployCommunity(uint index, bytes memory _data) public {
      require(implementationCommunityContract[index]!=address(0));
      address clone= Clones.clone(implementationCommunityContract[index]);  
      (bool success, bytes memory returnData) = clone.call(abi.encodeWithSignature("initialize(bytes,address)",_data,msg.sender));
      require(success && (returnData.length == 0 || abi.decode(returnData, (bool))), "Initialization Failed");
      communities.push(clone);
      totalCommunities+=1;
      emit CommunityCreated(index,clone);
    }
    function getCommunities() public view returns (address[] memory){
       return communities;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";
import "../src/DecentralizedSocialMedia.sol"; 
import {SocialToken} from "../src/SocialToken.sol";


contract SocialMediaTest is Test {
    DecentralizedSocialMedia public socialMedia; 
    SocialToken public socialToken; 
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
    socialToken = new SocialToken();
    socialMedia = new DecentralizedSocialMedia(address(socialToken));
    socialToken.setOwner(address(socialMedia));
}


    function testCreateProfile() public {
        vm.prank(alice);
        socialMedia.createProfile("Alice", "Alice's bio");

        (string memory username, string memory bio) = socialMedia.userProfiles(alice);

        assertEq(bio, "Alice's bio");
    
    }

    function testCreatePost() public {
        vm.prank(alice);
        socialMedia.createProfile("Alice", "Alice's bio");
        vm.prank(alice);
        socialMedia.createPost("Hello, world!", false);

       
        (
            uint256 postId,
            address author,
            string memory content,
            bool isPrivate,
            uint256 timestamp,
            uint256 likes,
            uint256 dislikes,
            DecentralizedSocialMedia.Comment[] memory comments
        ) = socialMedia.getPost(1);

        assertEq(postId, 1);
        assertEq(author, alice);
        assertEq(content, "Hello, world!");
        assertEq(isPrivate, false);
        assertEq(likes, 0);
        assertEq(dislikes, 0);
    }

    function testAddComment() public {
        vm.prank(alice);
        socialMedia.createProfile("Alice", "Alice's bio");
        vm.prank(alice);
        socialMedia.createPost("Hello, world!", false);
        vm.prank(bob);
        socialMedia.createProfile("Bob", "Bob's bio");
        vm.prank(bob);
        socialMedia.addComment(1, "Nice post!");

       
        (
            uint256 postId,
            address author,
            string memory content,
            bool isPrivate,
            uint256 timestamp,
            uint256 likes,
            uint256 dislikes,
            DecentralizedSocialMedia.Comment[] memory comments
        ) = socialMedia.getPost(1);

        assertEq(comments.length, 1);
        assertEq(comments[0].commenter, bob);
        assertEq(comments[0].content, "Nice post!");
    }

    function testReactToPost() public {
    
    vm.prank(alice);
    socialMedia.createProfile("Alice", "Alice's bio");
    vm.prank(alice);
    socialMedia.createPost("Hello, world!", false);
    vm.prank(bob);
    socialMedia.createProfile("Bob", "Bob's bio");

    vm.prank(bob);
    socialMedia.reactToPost(1, true); 
    (
        uint256 postId,
        address author,
        string memory content,
        bool isPrivate,
        uint256 timestamp,
        uint256 likes,
        uint256 dislikes,
        DecentralizedSocialMedia.Comment[] memory comments
    ) = socialMedia.getPost(1);

    assertEq(likes, 1, "Like count should be 1");
    assertEq(dislikes, 0, "Dislike count should be 0");
    uint256 aliceBalance = socialToken.balanceOf(alice);
   assertEq(aliceBalance, 10 * (10 ** socialToken.decimals()), "Alice should receive 10 SCT tokens for the like");
    vm.prank(bob);
    vm.expectRevert("You have already reacted to this post");
    socialMedia.reactToPost(1, true);
}


    function testCannotReactTwice() public {
        vm.prank(alice);
        socialMedia.createProfile("Alice", "Alice's bio");
        vm.prank(alice);
        socialMedia.createPost("Hello, world!", false);
        vm.prank(bob);
        socialMedia.reactToPost(1, true);
        vm.prank(bob);
        vm.expectRevert("You have already reacted to this post");
        socialMedia.reactToPost(1, true);
    }

    function testMintTokensOnlyByContract() public {
        vm.prank(bob);
        vm.expectRevert("Only the owner can call this function");
        socialToken.mint(bob, 1000);
    }

    function testFollowUser() public {
        vm.prank(alice);
        socialMedia.createProfile("Alice", "Alice's bio");
        vm.prank(bob);
        socialMedia.createProfile("Bob", "Bob's bio");
        vm.prank(bob);
        socialMedia.followUser(alice);
        address[] memory followers = socialMedia.getFollowers(alice);
        assertEq(followers.length, 1);
        assertEq(followers[0], bob);
    }
}


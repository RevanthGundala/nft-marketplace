// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace {
    struct Listing {
        address seller;
        uint price;
    }

    mapping(address => mapping(uint => Listing)) public listings;

    modifier isOwner(address nftAddress, uint tokenID) {
        require(IERC721(nftAddress).ownerOf(tokenID) == msg.sender);
        _;
    }

    modifier isNotListed(address nftAddress, uint tokenID) {
        require(listings[nftAddress][tokenID].price == 0);
        _;
    }

    modifier isListed(address nftAddress, uint tokenID) {
        require(listings[nftAddress][tokenID].price != 0);
        _;
    }

    event ListingCreated(
        address nftAddress,
        uint tokenID,
        uint price,
        address seller
    );

    event ListingDeleted(address nftAddress, uint tokenID, address seller);

    event ListingUpdated(
        address nftAddress,
        uint tokenID,
        uint newPrice,
        address seller
    );

    event ListingPurchased(
        address nftAddress,
        uint tokenID,
        address seller,
        address buyer
    );

    function createListing(
        address nftAddress,
        uint tokenID,
        uint price
    ) external isNotListed(nftAddress, tokenID) isOwner(nftAddress, tokenID) {
        require(price > 0);
        IERC721 nft = IERC721(nftAddress);
        require(
            nft.isApprovedForAll(msg.sender, address(this)) ||
                nft.getApproved(tokenID) == address(this)
        );
        listings[nftAddress][tokenID].price = price;
        listings[nftAddress][tokenID].seller = msg.sender;
        emit ListingCreated(nftAddress, tokenID, price, msg.sender);
    }

    function deleteListing(address nftAddress, uint tokenID)
        public
        isListed(nftAddress, tokenID)
        isOwner(nftAddress, tokenID)
    {
        Listing memory listing = listings[nftAddress][tokenID];
        delete listing;
        emit ListingDeleted(nftAddress, tokenID, msg.sender);
    }

    function updateListing(
        address nftAddress,
        uint tokenID,
        uint newPrice
    ) external isListed(nftAddress, tokenID) isOwner(nftAddress, tokenID) {
        require(newPrice >= 0);

        Listing memory listing = listings[nftAddress][tokenID];
        listing.price = newPrice;

        emit ListingUpdated(nftAddress, tokenID, newPrice, msg.sender);
    }

    function purchaseListing(address nftAddress, uint tokenID)
        external
        payable
        isListed(nftAddress, tokenID)
        isOwner(nftAddress, tokenID)
    {
        Listing memory listing = listings[nftAddress][tokenID];
        require(msg.value == listing.price);
        IERC721 nft = IERC721(nftAddress);
        nft.safeTransferFrom(listing.seller, msg.sender, tokenID);
        (bool success, ) = payable(listing.seller).call{value: msg.value}("");
        require(success);
        emit ListingPurchased(nftAddress, tokenID, listing.seller, msg.sender);
        deleteListing(nftAddress, tokenID);
    }

    function getListingPrice(address nftAddress, uint tokenID)
        external
        view
        isListed(nftAddress, tokenID)
        isOwner(nftAddress, tokenID)
        returns (uint)
    {
        Listing memory listing = listings[nftAddress][tokenID];
        return listing.price;
    }

    function getSeller(address nftAddress, uint tokenID)
        external
        view
        isListed(nftAddress, tokenID)
        isOwner(nftAddress, tokenID)
        returns (address)
    {
        Listing memory listing = listings[nftAddress][tokenID];
        return listing.seller;
    }
}

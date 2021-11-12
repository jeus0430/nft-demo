// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Pausable.sol";

contract Anony is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    bool public SALE_OPEN = false;

    uint256 private constant PRICE = 69 * 10**15; // 0.068ETH Per Anony
    uint256 private constant PRICE_PRESALE = 42 * 10**15; // 0.042ETH Per Anony

    uint256 private constant MAX_ELEMENTS = 2069; // 2069 Anonys for Entire Collection.
    uint256 private constant MAX_ELEMENTS_PRESALE = 420; // 420 Anonys for Pre Sale.

    uint256 private _price;
    uint256 private _maxElements;

    mapping(uint256 => bool) private _isOccupiedId;
    uint256[] private _occupiedList;

    bool private _isPresale;

    string private baseTokenURI;

    address private developerAddress = 0xDEA5e36DC33A3aed5CA275E463eDd283F680D1c6;

    event OnePieceCreated(address to, uint256 indexed id);

    modifier saleIsOpen {
        if (_msgSender() != owner()) {
            require(SALE_OPEN == true, "SALES: Please wait a big longer before buying Anonys ;)");
        }
        require(_totalSupply() <= MAX_ELEMENTS, "SALES: Sale end");

        if (_msgSender() != owner()) {
            require(!paused(), "PAUSABLE: Paused");
        }
        _;
    }

    constructor (string memory baseURI) ERC721("Anonys", "ANN") {
        setBaseURI(baseURI);
    }

    function startPreSale() public onlyOwner {
        _isPresale = true;
        SALE_OPEN = true;

        _price = PRICE_PRESALE;
        _maxElements = MAX_ELEMENTS_PRESALE;
    }

    function mint(address payable _to, uint256 memory _id) public payable saleIsOpen {
        uint256 total = _totalSupply();
        require(_isOccupiedId[_id] == false, "MINT: Those id already have been used for other customers");

        if (_to != owner()) {
            require(msg.value >= _price, "MINT: Current value is below the sales price of AnonyVerse");
        }

        _tokenIdTracker.increment();
        _safeMint(_to, _id);
        _isOccupiedId[_id] = true;
        _occupiedList.push(_id);

        emit OnePieceCreated(_to, _id);
    }

    function startPublicSale() public onlyOwner {
        _isPresale = false;

        SALE_OPEN = true;

        _price = PRICE;
        _maxElements = MAX_ELEMENTS;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }

    function occupiedList() public view returns (uint256[] memory) {
        return _occupiedList;
    }

    function maxMint() public view returns (uint256) {
        return _maxMint;
    }

    function maxSales() public view returns (uint256) {
        return _maxElements;
    }

    function maxSupply() public pure returns (uint256) {
        return MAX_ELEMENTS;
    }

    function raised() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenIdsOfWallet(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function withdrawAll() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "WITHDRAW: No balance in contract");

        _widthdraw(ownerAddress, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "WITHDRAW: Transfer failed.");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/ERC2981Interface.sol';

contract CoolPinapple is ERC721, Ownable, IERC2981Royalties {
    using Counters for Counters.Counter;

    struct RoyaltyInfo {
        address recipient;
        uint256 amount;
    }
    
    RoyaltyInfo private _royalties;

    //Interface for royalties
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    Counters.Counter private _tokenIds;

    bool private publicSaleIsOpen = false;

    //comparisons are strictly less than for gas efficiency.
    uint256 public constant MAX_SUPPLY = 10000;

    
    uint256 public constant PRICE = 0.1 ether;

    uint256 public constant MAX_PER_MINT = 6; //5
    uint256 public constant MAX_PER_WALLET = 6; //5

    uint96 public constant ROYALTIES_POINTS = 500; //5%

    string public baseTokenURI;

    event NFTMinted(uint256, uint256, address);

    //amount of mints that each address has executed.
    mapping(address => uint256) public mintsPerAddress;

    constructor(string memory baseURI) ERC721("NFTContract", "NFT") {
        baseTokenURI = baseURI;
        setRoyalties(owner(), ROYALTIES_POINTS);
        
    }

    //ensure that modified function cannot be called by another contract
    modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

    function _baseURI() internal view override returns (string memory) {
       return baseTokenURI;
    }
    
    function reveal(string memory _newBaseTokenURI) public onlyOwner {
        baseTokenURI = _newBaseTokenURI;
    }

    function openPublicSale() external onlyOwner {
        require(publicSaleIsOpen == false, 'Sale is already Open!');
        publicSaleIsOpen = true;
    }

    function mintNFTs(uint256 _number) public callerIsUser payable {
        uint256 totalMinted = _tokenIds.current();

        require(publicSaleIsOpen == true, "Opensale is not Open");
        require(totalMinted + _number < MAX_SUPPLY, "Not enough NFTs!");
        require(mintsPerAddress[msg.sender] + _number < MAX_PER_WALLET, "Cannot mint more than 5 NFTs per wallet");
        require(_number > 0 && _number < MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value == PRICE * _number , "Not enough/too much ether sent");
        
        mintsPerAddress[msg.sender] += _number;

        for (uint i = 0; i < _number; ++i) {
            _mintSingleNFT();
        }

        emit NFTMinted(_number, _tokenIds.current(), msg.sender);
    }


    function _mintSingleNFT() internal {
      uint newTokenID = _tokenIds.current();
      _safeMint(msg.sender, newTokenID);
      _tokenIds.increment();

    }

    function getCurrentId() public view returns (uint256) {
        return _tokenIds.current();
    }

//Withdraw money in contract to Owner
    function withdraw() external onlyOwner {
     uint256 balance = address(this).balance;
     require(balance > 0, "No ether left to withdraw");

     (bool success, ) = payable(owner()).call{value: balance}("");

     require(success, "Transfer failed.");
     
    }

    //interface for royalties
    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool){

        return interfaceId == type(IERC2981Royalties).interfaceId || super.supportsInterface(interfaceId);
    }

    function setRoyalties(address recipient, uint256 value) public onlyOwner {
        require(value <= 10000, 'ERC2981Royalties: Too high');

        _royalties = RoyaltyInfo(recipient, value);
    }

    function royaltyInfo(uint256, uint256 value) external view override returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }

        //fallback receive function
        receive() external payable { 
            revert();
    }
    
}
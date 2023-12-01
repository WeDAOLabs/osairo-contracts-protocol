//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./VRFv2Consumer.sol";

contract Land is
    ERC721,
    ERC721URIStorage,
    AccessControl
{
    event MintUrl(uint256 tokenId, string url);
    event Burn(address indexed user, uint256 indexed tokenId);

    uint256 public tokenId = 1;
    uint256 public MINT_FEE;
    string public BASE_URL;
    uint256 public MAX_NUM;
    //Land属性
    struct LandIndex {
        uint8 LevelOne;
        uint8 LevelTwo;
        uint8 LevelThree;
        uint8 LevelFour;
        uint256[] Loot;
    }

    //address => tokenid[]
    mapping(address => uint256[]) public userTokens;
    mapping (uint256=>LandIndex) Lands;
    VRFv2Consumer public VRF;

    constructor(address _VRFAddress) ERC721("Land","Land") {
        VRF = VRFv2Consumer(_VRFAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        setBaseUrl("https://example.com/land/");
        setMintFee(0.2 ether);
        setMaxNum(101 * 101);
    }

    //设置费用
    function setMintFee(uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        MINT_FEE = fee;
    }

    //设置URL
    function setBaseUrl(string memory url) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BASE_URL = url;
    }

    //设置Land最大数量
    function setMaxNum(uint256 num) public onlyRole(DEFAULT_ADMIN_ROLE) {
        MAX_NUM = num;
    }

    //管理员授权
    function setAdminRole(address admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    //管理员权限撤销
    function revokeAdminRole(
        address admin
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(DEFAULT_ADMIN_ROLE, admin);
    }

    //Mint
    function mint(uint256 num) public payable {
        require(num > 0 && num <= MAX_NUM, "Invalid mint amount");
        require(
            msg.value >= (MINT_FEE * (101) ** num) / (100 ** num),
            "Insufficient funds"
        );
        require(tokenId + num <= MAX_NUM, "Exceed max supply");

        for (uint i = 0; i < num; i++) {
            LandIndex memory index = initLand();
            Lands[tokenId] = index;
            userTokens[msg.sender].push(tokenId);
            string memory tokenURL = string(abi.encodePacked(BASE_URL, Strings.toString(tokenId)));
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, tokenURL);
            MINT_FEE = (MINT_FEE * 101) / 100;
            emit MintUrl(tokenId,tokenURL);
            tokenId++;
        }
    }

    
    function tokenURI(uint256 _tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return string(abi.encodePacked(BASE_URL, Strings.toString(tokenId)));
    }

    
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        return userTokens[owner];
    }

    function burn(uint256 _tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        emit Burn(msg.sender, tokenId);
        _burn(_tokenId);
    }

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage){
        address owner = ownerOf(_tokenId);
        _removeUserToken(owner, _tokenId);
        super._burn(_tokenId);
    }

    function transferfrom(address from, address to, uint256 _tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Transfer the token
        _transfer(from, to, _tokenId);

        // Remove the token from the sender's array
        _removeUserToken(from, _tokenId);

        // Add the token to the recipient's array
        userTokens[to].push(_tokenId);
    }

    function _removeUserToken(address owner, uint256 _tokenId) internal {
        uint256[] storage ownerTokens = userTokens[owner];
        // Remove the token from the owner's array
        for (uint256 i = 0; i < ownerTokens.length; i++) {
            if (ownerTokens[i] == _tokenId) {
                ownerTokens[i] = ownerTokens[ownerTokens.length - 1];
                ownerTokens.pop();
                break;
            }
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    //初始化Land
    function initLand() public returns (LandIndex memory land) {
        /*LandIndex memory _land;
        _land.LevelOne = 75;
        _land.LevelTwo = 20;
        _land.LevelThree = 5;
        _land.LevelFour = 0;
        _land.Loot = getRandomValue();
        return _land;*/
        return LandIndex(75,20,5,0,getRandomValue());
    }
    //获取随机数
    function getRandomValue() public returns(uint256[] memory){
        uint256 _requestId = VRF.requestRandomWords();
        uint256[] memory _data = new uint256[](10); 
        (,_data)= VRF.getRequestStatus(_requestId);
        return _data;
    }
    
}

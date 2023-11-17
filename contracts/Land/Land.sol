// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// contract Land is
//     ERC721,
//     ERC721URIStorage,
//     RandomNumber,
//     AccessControl,
//     VRFConsumerBaseV2
// {
//     event MintUrl(uint256 tokenId, string url);

//     uint256 public tokenId = 1;
//     uint256 public MINT_FEE;
//     string public BASE_URL;
//     uint256 public MAX_NUM;
//     //Land属性
//     struct LandIndex {
//         uint8 LevelOne;
//         uint8 Leveltwo;
//         uint8 LevelThree;
//         uint8 LevelFour;
//         uint256[10] Loot;
//     }

//     //address => tokenid[]
//     mapping(address => uint256[]) public userTokens;

//     constructor(
//         string memory name,
//         string memory symbol
//     ) ERC721("LAND", "LAND") {
//         _grantRole(DEFAULT_ADMIN_ROLE, admin);

//         setBaseUrl("https://");
//         setMintFee(0.2 ether);
//         setMaxNum(101 * 101);
//     }

//     //设置费用
//     function setMintFee(uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         MINT_FEE = fee;
//     }

//     //设置URL
//     function setBaseUrl(string memory url) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         BASE_URL = url;
//     }

//     //设置Land最大数量
//     function setMaxNum(uint256 num) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         MAX_NUM = num;
//     }

//     //管理员授权
//     function setAdminRole(address admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         _grantRole(DEFAULT_ADMIN_ROLE, admin);
//     }

//     //管理员权限撤销
//     function revokeAdminRole(
//         address admin
//     ) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         _revokeRole(DEFAULT_ADMIN_ROLE, admin);
//     }

//     //Mint
//     function mint(uint256 num) public payable {
//         require(num > 0 && num <= MAX_NUM, "Invalid mint amount");
//         require(
//             msg.value >= (MINT_FEE * (101) ** num) / 100 ** num,
//             "Insufficient funds"
//         );
//         require(tokenId + num <= MAX_NUM, "Exceed max supply");

//         for (uint i = 0; i < num; i++) {
//             _safeMint(msg.sender, tokenId);
//             MINT_FEE = (MINT_FEE * 101) / 100;
//             emit MintUrl(
//                 tokenId,
//                 string(abi.encodePacked(BASE_URL, Strings.toString(tokenId)))
//             );
//             tokenId++;
//         }
//     }

//     //获取URL
//     function tokenURI(
//         uint256 tokenId
//     ) public view override returns (string memory) {
//         require(
//             _exists(tokenId),
//             "ERC721Metadata: URI query for nonexistent token"
//         );

//         return string(abi.encodePacked(BASE_URL, Strings.toString(tokenId)));
//     }

//     //获取owner
//     function tokensOfOwner(
//         address owner
//     ) external view returns (uint256[] memory) {
//         return userTokens[owner];
//     }

//     //初始化Land
//     function initLand(uint256 seed) internal returns (LandIndex memory land) {
//         LandIndex memory _land;
//         _land.LevelOne = 75;
//         _land.Leveltwo = 20;
//         _land.LevelThree = 5;
//         _land.LevelFour = 0;
//         _land.Loot[0] = randomNumber(seed);
//     }
// }

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract OsairoLandTileDynamicNFT is
    ERC721Enumerable,
    VRFConsumerBaseV2,
    AccessControlEnumerable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;

    string[] private tileTypes = [
        "Enchanted Forest",
        "Lava Fields",
        "Crystal Canyon",
        "Ancient Ruins",
        "Ethereal Meadows",
        "Whispering Hills",
        "Frozen Wasteland",
        "Emerald Oasis",
        "Endless Sands"
    ];

    Counters.Counter private _tokenIdTracker;

    event LandTileMint(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    VRFCoordinatorV2Interface immutable COORDINATOR;

    // Your subscription ID.
    uint64 immutable s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 immutable s_keyHash;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 constant NUM_WORDS = 10;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    // TODO need set when request words
    uint32 constant CALLBACK_GAS_LIMIT = 26000 * NUM_WORDS;

    // The default is 3, but you can set this higher.
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    mapping(uint256 => uint256[]) private _sTokenIdToRandomWords;

    mapping(uint256 => address) private _sRequestIdToAddress;

    uint256 private _currentTokenId;

    uint public constant totalTileCount = 101 * 101;

    string private constant _baseTokenURI =
        "https://testnet.osairo.xyz/land_nft/osairo_land_tile_";

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash
    ) ERC721("OsairoLandTile", "OLT") VRFConsumerBaseV2(vrfCoordinator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;

        _currentTokenId = 0;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(tokenId >= 1, "Token ID must be greater than 0");

        uint256[] memory properties = _sTokenIdToRandomWords[tokenId];
        uint256 randomIndex = properties[0] % tileTypes.length;
        string memory tileName = tileTypes[randomIndex];

        string memory imgUri = string(
            abi.encodePacked(
                _baseTokenURI,
                Strings.toString(randomIndex),
                ".png"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        tileName,
                        '",',
                        '"description": "One piece of Osairo island",',
                        '"image": "',
                        imgUri,
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return finalTokenURI;
    }

    function requestRandomWords(uint32 numWords) internal returns (uint256) {
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            numWords
        );
        return requestId;
    }

    function mintLandTile(address to) public onlyRole(MINTER_ROLE) {
        uint256 requestId = requestRandomWords(NUM_WORDS);
        _sRequestIdToAddress[requestId] = to;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address to = _sRequestIdToAddress[requestId];

        uint256 _tokenId = _tokenIdTracker.current() + 1;

        _safeMint(to, _tokenId);

        _sTokenIdToRandomWords[_tokenId] = randomWords;

        _tokenIdTracker.increment();

        emit LandTileMint(address(0), to, _tokenId);
    }

    function randomProperty(
        uint256 tokenId,
        uint8 index
    ) public view returns (uint256) {
        uint256[] memory randomProperties = _sTokenIdToRandomWords[tokenId];
        require(
            randomProperties.length > index,
            "property index exceeds limit"
        );

        return randomProperties[index];
    }

    function _mint(address to, uint256 tokenId) internal override {
        require(totalSupply() < totalTileCount, "There's none tile left.");
        super._mint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Enumerable, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

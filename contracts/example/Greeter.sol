//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.21;
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Greeter is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    string private greeting;

    event GreetingChanged(address from, string _greeting);

    event BuildTokenUri(string tokenUri);

    // the role that can pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // the role that used for upgrading the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    // the role that used for setting the greeting
    bytes32 public constant SET_GREETING_ROLE = keccak256("SET_GREETING_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _greeting) public initializer {
        greeting = _greeting;
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(SET_GREETING_ROLE, msg.sender);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(
        string memory _greeting
    ) public whenNotPaused onlyRole(SET_GREETING_ROLE) {
        greeting = _greeting;

        emit GreetingChanged(msg.sender, _greeting);
    }

    function updateFillColor() internal pure returns (string memory) {
        return string(abi.encodePacked("#", "1", "3", "5", "2", "4", "0"));
    }

    function tokenURI() public returns (string memory) {
        string memory fillColor = updateFillColor();
        // Create SVG rectangle with color
        string memory imgSVG = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:svgjs='http://svgjs.com/svgjs' width='500' height='500' preserveAspectRatio='none' viewBox='0 0 500 500'> <rect width='100%' height='100%' fill='",
                fillColor,
                "' />",
                "<text x='50%' y='50%' font-size='128' dominant-baseline='middle' text-anchor='middle'>",
                unicode"😀",
                "</text>",
                "</svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "ETH Watching SVG",',
                        '"description": "An Automated ETH tracking SVG",',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(imgSVG)),
                        '"}'
                    )
                )
            )
        );

        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        emit BuildTokenUri(finalTokenURI);
        return finalTokenURI;
    }
}

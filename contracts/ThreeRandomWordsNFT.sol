// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract ThreeRandomWordsNFT is ERC721URIStorage {

  // Here we import the counter
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string baseSvgPreColor = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string baseSvgPostColor = "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // Three arrays, each with their own theme of random words.
  string[] firstWords = ["Dominant", "Submissive", "Barking", "Savage", "Constant", "Dynamic", "Superlative", "Animated", "Holographic", "Cyborg", "Chrome", "Rainbow", "Extravagant", "Nonsensical", "Miniature", "Defective", "Adopted", "Bottled", "Supreme", "Dilapitated", "Rare", "Ultimate", "Golden", "Undead", "Dwarven", "Eleven", "Microscopic", "Genetic", "Supernatural", "Luxurious", "Laughing", "Crying"];
  string[] secondWords = ["Jellyfish", "Muffin", "Cheddar", "Alpaca", "Cannabis", "Mackerel", "Spanking", "Manatee", "Zombie", "Ostrich", "Flugelhorn", "Tornado", "YoYo", "Arachnid", "Lollipop", "Diamond", "Ruby", "Emerald", "Sapphire", "Amethyst", "Pearl", "Oak", "Mahogany", "Maple", "Cedar", "Aluminum", "Copper", "Marble", "Titanium", "Platinum"];
  string[] thirdWords = ["Whisperer", "Saviour", "Plumber", "Wrangler", "Sergeant", "Rider", "Machine", "Goddess", "Hostage", "Volunteer", "Detective", "Relative", "Twin", "Triplet", "Cousin", "Goblin", "Finale", "Defendant", "Prosecutor", "Executor", "Orc", "Dentist", "Fighter", "Ranger", "Barbarian", "Wizard", "Sorceress", "Necromancer", "Blanket", "Hoodie", "Saddle", "Fannypack", "Swimsuit", "Wench", "Mermaid", "Toadstool", "Hammock", "Savant"];
  
  string[] colors = ["darkorchid", "chartreuse", "deeppink", "cornsilk", "coral", "darkgoldenrod", "lemonchiffon", "lavenderblush", "honeydew", "yellowgreen", "turquoise", "tomato", "orangered", "olivedrab", "orchid", "palegreen", "magenta", "lime"];

  event NewThreeRandomWordNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("NFTSouls Test", "SQUARE") {

  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 colorIndex;
    if(tokenId <=  colors.length - 1){
      colorIndex = tokenId;
    } else {
      colorIndex = tokenId % colors.length;
    }

    return colors[colorIndex];
  }

  function makeAnNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));
    string memory randomColor = pickRandomColor(newItemId);

    string memory finalSvg = string(abi.encodePacked(baseSvgPreColor, randomColor, baseSvgPostColor, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A collection of generative works, testing for NFTSouls Project.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    // We need to increment
    _tokenIds.increment();
  
    emit NewThreeRandomWordNFTMinted(msg.sender, newItemId);
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    
  }
}
pragma solidity ^0.4.24;

/*
    Copyright 2018-2019, Michal R. Hoffman <M.R.Hoffman@soton.ac.uk>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";

//Smart Papers factory contract

contract SmartPapersApp is AragonApp {
    using SafeMath for uint256;

    /// Events
    event IncrementCitations(address indexed entity, uint256 step);
    event DecrementCitations(address indexed entity, uint256 step);
    event CreatePaper(address indexed entity, uint256 paperId);

    /// State
    uint256 public value;

    /// ACL
    bytes32 constant public INCREMENT_CITATIONS_ROLE = keccak256("INCREMENT_CITATIONS_ROLE");
    bytes32 constant public DECREMENT_CITATIONS_ROLE = keccak256("DECREMENT_CITATIONS_ROLE");
    string private constant ERROR_NO_PAPER = "PAPER_DOES_NOT_EXIST";
    string private constant ERROR_NO_VERSION = "VERSION_DOES_NOT_EXIST";
    bytes32 public constant CREATE_PAPERS_ROLE = keccak256("CREATE_PAPERS_ROLE");

    function initialize() onlyInit public {
        initialized();
    }

    struct SmartPaper{
         uint64 paperId;
         address creator;
         address[] collaborators; //excluding creator
         uint64 creationTime;
         uint256 quorumPct; //setting to 50% would be 'simple democracy'
         uint256 votingPower;  // total tokens that can vote, should = 1 + no. collabs
         string metadata; //JSON-LD 1.0
         uint256[] versionIds; //the length of this array is number of versions
         bool published;
         uint256 publishedVersionId; //set if published
         uint64 citationCount;
    }

    struct Version{
        uint256 versionId;
        address initiator; //should normally be the same as paper creator
        address[] collaborators; //should normally be the same as paper collabs
        uint64 creationtime;
        string metadata; //JSON-LD 1.0
        IpfsMultihash artifactAddress; //link to the paper in IPFS
        bool published;     
    }

    mapping(uint256 => uint64) versionToPaper;

    struct IpfsMultihash {
        bytes32 digest;
        uint8 hashFunction;
        uint8 size;
    }

    mapping (uint64 => SmartPaper) internal papers;
    mapping (uint256 => Version) internal versions;

    uint64 public numPapers;
    uint256 public numVersions;

    modifier paperExists(uint64  _paperId) {
        require(_paperId < numPapers, ERROR_NO_PAPER);
        _;
    }

    modifier versionExists (uint256 _versionId) {
        require(_versionId < numVersions, ERROR_NO_VERSION);
        _;
     }

    mapping (uint64 => address) ORCID_Ethereum_mapping;

    function getAddressFromOrcid(uint64 _ORCID) view public returns (address){
      return ORCID_Ethereum_mapping[_ORCID];
    }

    /**
     * @notice Increment the counter by `step`
     * @param step Amount to increment by
     */
    function incrementCitations(uint256 step) auth(INCREMENT_CITATIONS_ROLE) external {
        value = value.add(step);
        emit IncrementCitations(msg.sender, step);
    }

    /**
     * @notice Decrement the counter by `step`
     * @param step Amount to decrement by
     */
    function decrementCitations(uint256 step) auth(DECREMENT_CITATIONS_ROLE) external {
        value = value.sub(step);
        emit DecrementCitations(msg.sender, step);
    }

    /**
     * @notice Create a new SmartPaper with an initial Version
     * @param _metadata The metadata identifying this paper
     */
    function newPaper(string _metadata) external auth(CREATE_PAPERS_ROLE) returns (uint64 paperId) {
        paperId = numPapers++;
	uint256 versionId = numVersions++;
        papers[paperId] = SmartPaper(paperId, msg.sender, new address[](0), getTimestamp64(),
			 50*10e16, 1, _metadata, new uint256[](0), false, 0, 0);
	versions[versionId] = Version(versionId, msg.sender, new address[](0),
                        getTimestamp64(), "InitialVersion", IpfsMultihash(0,0,0), false);
	papers[paperId].versionIds.push(versionId);
        emit CreatePaper(msg.sender, paperId);
    }
}

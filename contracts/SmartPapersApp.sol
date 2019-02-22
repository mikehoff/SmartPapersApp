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
    string private constant ERROR_NO_PAPER = "PAPER_NOT_EXIST";
    bytes32 public constant CREATE_PAPERS_ROLE = keccak256("CREATE_PAPERS_ROLE");

    function initialize() onlyInit public {
        initialized();
    }

    struct SmartPaper{
         address creator;
         address[] collaborators;
         uint64 creationTime;
         uint256 quorumPct; //setting to 50% would be 'simple democracy'
         uint256 votingPower;  // total tokens that can vote, should = 1 + no. collabs
         string metadata;
    }

    mapping (uint256 => SmartPaper) internal papers;
    uint256 public numPapers;
    modifier paperxists(uint256 _paperId) {
        require(_paperId < numPapers, ERROR_NO_PAPER);
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
     * @notice Create a new SmartPaper
     * @param _metadata The metadata identifying this paper
     */
    function newPaper(string _metadata) external auth(CREATE_PAPERS_ROLE) returns (uint256 paperId) {
        paperId = numPapers++;
        SmartPaper storage paper = papers[paperId];
        paper.creator = msg.sender;
        paper.creationTime = getTimestamp64();
        paper.metadata = _metadata;
        paper.quorumPct = 0;
        emit CreatePaper(paper.creator, paperId);
    }
}

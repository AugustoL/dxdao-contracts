pragma solidity ^0.5.2;

import "../universalSchemes/UniversalScheme.sol";
import "@daostack/infra/contracts/votingMachines/GenesisProtocol.sol";


contract VotingMachineCallbacks is VotingMachineCallbacksInterface {

    struct ProposalInfo {
        uint256 blockNumber; // the proposal's block number
        Avatar avatar; // the proposal's avatar
        address votingMachine;
    }

    modifier onlyVotingMachine(bytes32 _proposalId) {
        require(msg.sender == proposalsInfo[_proposalId].votingMachine, "only VotingMachine");
        _;
    }

            //proposalId ->     ProposalInfo
    mapping(bytes32      =>     ProposalInfo    ) public proposalsInfo;

    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return ControllerInterface(avatar.owner()).mintReputation(_amount, _beneficiary, address(avatar));
    }

    function burnReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return ControllerInterface(avatar.owner()).burnReputation(_amount, _beneficiary, address(avatar));
    }

    function stakingTokenTransfer(
        ERC20 _stakingToken,
        address _beneficiary,
        uint256 _amount,
        bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return ControllerInterface(avatar.owner()).externalTokenTransfer(_stakingToken, _beneficiary, _amount, avatar);
    }

    function balanceOfStakingToken(ERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256) {
        Avatar avatar = proposalsInfo[_proposalId].avatar;
        if (proposalsInfo[_proposalId].avatar == Avatar(0)) {
            return 0;
        }
        return _stakingToken.balanceOf(address(avatar));
    }

    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256) {
        ProposalInfo memory proposal = proposalsInfo[_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().totalSupplyAt(proposal.blockNumber);
    }

    function reputationOf(address _owner, bytes32 _proposalId) external view returns(uint256) {
        ProposalInfo memory proposal = proposalsInfo[_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().balanceOfAt(_owner, proposal.blockNumber);
    }
}

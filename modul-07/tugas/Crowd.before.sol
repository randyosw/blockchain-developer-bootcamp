// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address payable owner;
        uint goal;
        uint deadline;
        uint fundsRaised;
        bool claimed;
        address[] contributors;
        mapping(address => uint) contributions;
    }

    uint public numCampaigns;
    mapping(uint => Campaign) public campaigns;

    event CampaignCreated(uint campaignId, address owner, uint goal, uint deadline);
    event ContributionMade(uint campaignId, address contributor, uint amount);
    event FundsClaimed(uint campaignId);
    event ContributionWithdrawn(uint campaignId, address contributor, uint amount);
    event CampaignRefunded(uint campaignId);

    error InvalidGoal();
    error CampaignEnded();
    error InvalidContribution();
    error GoalNotReached();
    error AlreadyClaimed();
    error NoContribution();
    error CampaignStillActive();

    function createCampaign(uint goal, uint durationInMinutes) external {
        if (goal <= 0) {
            revert InvalidGoal();
        }
        
        uint deadline = block.timestamp + durationInMinutes * 1 minutes;
        Campaign storage newCampaign = campaigns[numCampaigns];
        newCampaign.owner = payable(msg.sender);
        newCampaign.goal = goal;
        newCampaign.deadline = deadline;

        emit CampaignCreated(numCampaigns, msg.sender, goal, deadline);
        numCampaigns++;
    }

    function contribute(uint campaignId) external payable {
        Campaign storage campaign = campaigns[campaignId];

        if (block.timestamp >= campaign.deadline) {
            revert CampaignEnded();
        }

        if (msg.value <= 0) {
            revert InvalidContribution();
        }

        campaign.fundsRaised += msg.value;
        if (campaign.contributions[msg.sender] == 0) {
            campaign.contributors.push(msg.sender);
        }
        campaign.contributions[msg.sender] += msg.value;

        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    function claimFunds(uint campaignId) external {
        Campaign storage campaign = campaigns[campaignId];

        if (block.timestamp < campaign.deadline) {
            revert CampaignStillActive();
        }

        if (campaign.fundsRaised < campaign.goal) {
            revert GoalNotReached();
        }

        if (campaign.claimed) {
            revert AlreadyClaimed();
        }

        // Update state before transferring funds
        campaign.claimed = true;
        uint amount = campaign.fundsRaised;
        campaign.fundsRaised = 0;

        emit FundsClaimed(campaignId);

        // Transfer funds after state change
        campaign.owner.transfer(amount);
    }

    function withdrawContribution(uint campaignId) external {
        Campaign storage campaign = campaigns[campaignId];

        if (block.timestamp >= campaign.deadline) {
            revert CampaignEnded();
        }

        uint contribution = campaign.contributions[msg.sender];
        if (contribution == 0) {
            revert NoContribution();
        }

        // Update state before transferring funds
        campaign.fundsRaised -= contribution;
        campaign.contributions[msg.sender] = 0;

        emit ContributionWithdrawn(campaignId, msg.sender, contribution);

        // Transfer funds after state change
        payable(msg.sender).transfer(contribution);
    }

    function refundCampaign(uint campaignId) external {
    Campaign storage campaign = campaigns[campaignId];

    if (block.timestamp < campaign.deadline) {
        revert CampaignStillActive();
    }

    if (campaign.fundsRaised >= campaign.goal) {
        revert GoalNotReached();
    }

    // Iterate through contributors and refund their contributions
    for (uint i = 0; i < campaign.contributors.length; i++) {
        address contributor = campaign.contributors[i];
        uint contribution = campaign.contributions[contributor];

        if (contribution > 0) {
            // Update state before transferring funds
            campaign.contributions[contributor] = 0;

            // Transfer funds after state change
            payable(contributor).transfer(contribution);
            }
        }
    // Emit event after all contributions have been refunded
    emit CampaignRefunded(campaignId);
    }
}

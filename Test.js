const Crowdfunding = artifacts.require("Crowdfunding");
const MyToken = artifacts.require("MyToken");

contract("Crowdfunding", (accounts) => {
  let crowdfunding;
  let token;

  beforeEach(async () => {
    token = await MyToken.new();
    // Give some tokens to the first account
    await token.mint(accounts[0], 100);
    // Create the crowdfunding contract
    crowdfunding = await Crowdfunding.new(token.address, accounts[0], 50, Date.now() + 1000);
  });

  it("should allow users to make pledges", async () => {
    // Make a pledge of 10 tokens from the first account
    await crowdfunding.makePledge(10, { from: accounts[0] });
    // Check that the pledge was successful
    assert.equal(await crowdfunding.pledges(accounts[0]), 10);
    assert.equal(await crowdfunding.totalPledges(), 10);
  });

  it("should allow the campaign creator to claim the funds if the campaign goal is reached", async () => {
    // Make a pledge of 50 tokens from the first account
    await crowdfunding.makePledge(50, { from: accounts[0] });
    // Check that the campaign goal has been reached
    assert.equal(await crowdfunding.totalPledges(), 50);
    // Claim the funds
    await crowdfunding.claimFunds({ from: accounts[0] });
    // Check that the campaign creator has received the funds
    assert.equal(await token.balanceOf(accounts[0]), 150);
  });

  it("should allow users to withdraw their pledges if the campaign goal is not reached", async () => {
    // Make a pledge of 10 tokens from the first account
    await crowdfunding.makePledge(10, { from: accounts[0] });
    // Wait for the campaign to end
    await new Promise((resolve) => setTimeout(resolve, 1000));
    // Check that the campaign goal has not been reached
    assert.equal(await crowdfunding.totalPledges(), 10);
    // Withdraw the pledge
    await crowdfunding.withdrawPledge(10, { from: accounts[0] });
    // Check that the first account has received the tokens back
    assert.equal(await token.balanceOf(accounts[0]), 110);
  });
});

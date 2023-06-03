const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTTicket", function () {
  let gbrToken, nftTicket, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    // Deploy GBRToken mock
    const GBRTokenMock = await ethers.getContractFactory("ERC20Mock");
    gbrToken = await GBRTokenMock.deploy("GBR Token", "GBR", owner.address, ethers.utils.parseEther("1000000000000"));

    // Deploy NFTTicket
    const NFTTicket = await ethers.getContractFactory("NFTTicket");
    nftTicket = await NFTTicket.connect(owner).deploy(gbrToken.address, ethers.utils.parseEther("10"));
  });

  it("Should successfully change the ticket price if the function was called by the owner", async function () {
    // Change Ticket Price
    await nftTicket.connect(owner).changeTicketPrice(ethers.utils.parseEther("11"));

    // Check Ticket Price
    expect(await nftTicket.ticketPrice()).to.equal(ethers.utils.parseEther("11"));

    // revert when non-owner tries to withdraw tokens
    await expect(
      nftTicket.connect(addr1).changeTicketPrice(ethers.utils.parseEther("100"))
    ).to.be.revertedWith("Only contract owner can call this function");
  });

  it("Should successfully sell a new ticket to the user", async function () {
    // Sell New Ticket to user
    await gbrToken.connect(owner).approve(nftTicket.address, ethers.utils.parseEther("10"));

    await nftTicket.connect(owner).buyTicket("test", "test1");

    expect(await nftTicket.ticketsCount()).to.equal(1);
  });
});

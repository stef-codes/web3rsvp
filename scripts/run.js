const hre = require("hardhat"); 

const main = async () => {
  // use hardhat to deploy the contract locally 
  const rsvpContractFactory = await hre.ethers.getContractFactory("Web3RSVP");
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  console.log("Contract deployed to:", rsvpContract.address);

  // allow contract to interact with different wallets
  const [deployer, address1, address2] = await hre.ethers.getSigners();
  
  // test creating a new event
  let deposit = hre.ethers.utils.parseEther("1");
  let maxCapacity = 3;
  let timestamp = 1718926200;
  let eventDataCID =
    "bafybeibhwfzx6oo5rymsxmkdxpmkfwyvbjrrwcl7cekmbzlupmp5ypkyfi";
}; 
  
  let txn = await rsvpContract.createNewEvent(
    timestamp, 
    deposit, 
    maxCapacity, 
    eventDataCID
  ); 
  
  let wait = await txn.wait(); 
  console.log("NEW EVENT CREATED:", wait.events[0].event, wait.events[0].args); 
 
  let eventID = wait.events[0].args.eventID; 
  console.log("EVENT ID:", eventID)

  //



const runMain = async () => {
  try {
    await main(); 
    Process.exit(0); 
  } catch (error) {
    console.log(error); 
    process.exit(1); 
  }

}; 

runMain(); 
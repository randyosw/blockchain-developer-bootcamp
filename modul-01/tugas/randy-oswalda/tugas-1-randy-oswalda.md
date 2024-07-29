# Open-ended Questions

1. Why did we create this unit called gas?
    [Jawaban #1]
    Gas refers to the unit that measures the amount of computational effort required to execute specific operations on the Ethereum network.

2. What happen if these 2 hypothetical transactions were sent? *
- Bob only has 1 ether in his wallet
- Bob sends 1 ether to Alice with Tx 1
- At the same time, Bob sends 1 ether to Jim with Tx 2
    [Jawaban #2]
    Alice will receive 1 Ether, and the transaction to Jim will not succeed. Jim will not receive any Ether, and Bob's account will be nearly empty or completely empty after the successful transaction to Alice.

3. Since Ethereum is Turing complete, is it possible to do all kind of computation?
    [Jawaban #3]
    Yes it can, Ethereum can perform any computation that a Turing machine can, given enough time and resources. This includes any calculation or logic that can be represented algorithmically

4. How do you implement a CRON job in a smart contract?
    [Jawaban #4]
    It doesnt work in my opinion, but there's other alternative by using decentralized oracles or block timestamps

5. Since there is no OPCODE for http calls, how do you get outside data?
    [Jawaban $5]
    By using oracles like Chainlink, we can bridge the information between smart contracts and the outside data, allowing decentralized applications to access the external data.


* This is a theoretical questions, we don't refer to any existing transactions
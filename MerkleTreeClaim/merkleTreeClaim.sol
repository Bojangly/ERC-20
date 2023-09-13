   
   // Can be expanded to include multiple tiers by including multiple trees
   // airdropAmt is amount of each claim in tokens
   // metkleRoot is the root of the tree
   // merkleProof is sent from the FE
   // Contract must have tokens for claim to succeed
   function claimAirdrop(bytes32[] calldata _merkleProof) public {
        require(!airdropClaimed[msg.sender], "Address has already claimed.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(verify(_merkleProof, merkleRoot, leaf), "Invalid proof");
    
        // set boolean prior to updating balances to protect against reentrancy attacks
        airdropClaimed[msg.sender] = true;

        _balances[address(this)]=_balances[address(this)].sub(airdropAmt);
        _balances[msg.sender]=_balances[msg.sender].add(airdropAmt);
        airdropClaimedAmt = airdropClaimedAmt + airdropAmt;
        emit Transfer(address(this), msg.sender, airdropAmt);
    }

   function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) private pure returns (bool){
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Concatenate the hashes and recompute the hash
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Concatenate the hashes and recompute the hash
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash matches the root of the Merkle tree
        return computedHash == root;
    }
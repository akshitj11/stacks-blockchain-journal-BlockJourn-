import { Cl, cvToValue } from '@stacks/transactions';
import { describe, expect, it } from 'vitest';

// --- Test Suite: BlockJourn Contract ---
describe('BlockJourn Smart Contract', () => {
  // Get the accounts and contract name from the testing environment
  const accounts = simnet.getAccounts();
  const deployer = accounts.get('deployer')!;
  const user1 = accounts.get('wallet_1')!;
  const contractName = 'blockjournproject';

  // --- Test Case: Add First Entry ---
  it('allows a user to add their first journal entry', () => {
    // Arrange: Define the test data
    const entryContent = 'My first crypto insight!';
    const genesisHash = new Uint8Array(32); // A dummy 32-byte hash for the first entry
    const dummyTimestamp = 1; // Provide a dummy timestamp

    // Act: Call the 'add-entry' public function
    const response = simnet.callPublicFn(
      contractName,
      'add-entry',
      [
        Cl.stringUtf8(entryContent),
        Cl.buffer(genesisHash),
        Cl.uint(dummyTimestamp),
      ],
      user1
    );

    // Assert: Check that the transaction was successful and returned (ok u1)
    expect(response.result).toBeOk(Cl.uint(1));

    // Assert: Check that the user's entry count is now 1
    const entryCount = simnet.callReadOnlyFn(
      contractName,
      'get-entry-count',
      [Cl.principal(user1)],
      deployer
    );
    expect(entryCount.result).toBeOk(Cl.uint(1));
  });
});

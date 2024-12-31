# Clarity EcoTokens Smart Contract - Green Energy Incentive Marketplace

## Overview

The EcoTokens Smart Contract is designed to facilitate a decentralized marketplace for the exchange of green energy, providing users with the ability to purchase and sell energy using EcoTokens. This contract integrates tokenized incentives to encourage sustainable energy practices, utilizing Clarity Smart Contracts on the Stacks blockchain. It offers comprehensive features for users, administrators, and market participants to manage energy reserves, set transaction fees, and execute energy transactions securely.

### Key Features:
- **EcoTokens**: A tokenized incentive system for the purchase and sale of green energy.
- **Energy Management**: Users can list energy for sale, and admins can manage energy reserve limits.
- **Transaction Fees**: Admins can set and modify transaction fees for energy purchases.
- **Refund System**: Allows users to receive refunds for energy purchases based on the conditions defined in the contract.
- **Token Balance Management**: Each user’s EcoToken balance is tracked and validated before transactions.
- **Transparency**: The system ensures fair pricing, cap limits, and proper handling of energy reserves.

## Contract Description

This contract enables the creation, management, and exchange of EcoTokens (a green energy incentive token). The contract allows users to:
- List energy for sale.
- Buy energy using EcoTokens.
- Request refunds if needed.

The contract also provides the administrator with control over various aspects:
- Set EcoToken prices.
- Modify transaction fees.
- Adjust energy reserve caps.

### Functionalities:
- **Admin Controls**:
  - Set EcoToken price.
  - Set transaction fee percentage.
  - Adjust energy reserve cap.
  - Set user energy caps.
  - Adjust refund percentage.

- **User Operations**:
  - List energy for sale.
  - Purchase energy.
  - Remove energy from sale.
  - Request refunds.

## Contract Functions

### Admin Functions:
- **set-eco-token-price**: Allows the admin to set the price per EcoToken.
- **set-transaction-fee**: Adjusts the transaction fee percentage.
- **set-energy-reserve-cap**: Sets the maximum energy reserve for the marketplace.
- **set-user-energy-cap**: Defines the maximum energy a user can sell.
- **set-refund-percentage**: Adjusts the refund percentage for energy purchases.

### User Functions:
- **list-energy-for-sale**: Lets users list their energy for sale by specifying an amount and price.
- **purchase-energy**: Enables users to buy energy from others on the marketplace.
- **remove-energy-from-sale**: Allows users to remove energy listings.
- **refund-energy**: Provides refunds to users for their energy purchases based on the refund percentage.

### Read-only Functions:
- **get-eco-token-price**: Returns the current price of EcoTokens.
- **get-transaction-fee**: Returns the current transaction fee percentage.
- **get-energy-reserve**: Retrieves the total energy reserve available.
- **get-energy-listing**: Shows the details of a specific energy listing.
- **get-eco-token-balance**: Fetches a user's EcoToken balance.
- **get-user-energy-cap**: Returns the user's energy cap.

## Error Handling

The contract includes various error codes to ensure the integrity of transactions and operations:

- **err-insufficient-tokens**: Insufficient balance of EcoTokens.
- **err-transfer-failed**: Failed transaction transfer.
- **err-invalid-amount**: Invalid amount specified.
- **err-unauthorized**: Unauthorized access attempt.
- **err-price-too-low**: Price set is too low.
- **err-fee-exceeds-limit**: Transaction fee exceeds allowed limits.
- **err-max-reserve-exceeded**: Energy reserve exceeds the maximum limit.
- **err-not-enough-balance**: Insufficient balance for an operation.

## Example Usage

### 1. Listing Energy for Sale
To list energy for sale, a user must specify the amount of energy (in kWh) and the price per unit. The system checks that the user has sufficient EcoTokens and reserves the specified energy for sale.

```clarity
(list-energy-for-sale amount price)
```

### 2. Purchasing Energy
To purchase energy from another user, specify the seller and the amount of energy. The system deducts EcoTokens from the buyer's balance and updates the seller’s balance.

```clarity
(purchase-energy seller amount)
```

### 3. Setting the EcoToken Price
Only the admin can set the price of EcoTokens, which impacts the transactions on the marketplace.

```clarity
(set-eco-token-price new-price)
```

## Installation and Setup

1. **Install Stacks CLI**: Ensure that you have the Stacks CLI installed to deploy and interact with Clarity Smart Contracts.
2. **Deploy the Contract**: Use the `clarinet deploy` command to deploy the EcoTokens Smart Contract to the Stacks blockchain.
3. **Interact with the Contract**: Use Stacks Explorer or a custom interface to interact with the contract. You can perform transactions such as listing energy for sale, purchasing energy, and modifying contract parameters.

## Security Considerations

This contract enforces stringent checks to ensure that only authorized actions are performed:
- Only admins can change key parameters like the EcoToken price and transaction fees.
- Users are prevented from performing operations beyond their energy cap or EcoToken balance.
- The system prevents energy reserve limits from being exceeded.

## Contributing

Contributions to this contract are welcome! If you find bugs, or have suggestions for improvements, please feel free to fork the repository and submit a pull request. Ensure that all changes are thoroughly tested before submitting.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- **Blessing Adewale** - *Lead Developer*

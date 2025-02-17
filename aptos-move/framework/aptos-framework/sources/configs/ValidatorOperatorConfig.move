/// Stores the string name of a ValidatorOperator account.
module AptosFramework::ValidatorOperatorConfig {
    use Std::Capability::Cap;
    use Std::Errors;
    use Std::Signer;
    use AptosFramework::Timestamp;
    use AptosFramework::SystemAddresses;

    /// Marker to be stored under @CoreResources during genesis
    struct ValidatorOperatorConfigChainMarker<phantom T> has key {}

    struct ValidatorOperatorConfig has key {
        /// The human readable name of this entity. Immutable.
        human_name: vector<u8>,
    }

    /// The `ValidatorOperatorConfig` was not in the required state
    const EVALIDATOR_OPERATOR_CONFIG: u64 = 0;
    /// The `ValidatorOperatorConfigChainMarker` resource was not in the required state
    const ECHAIN_MARKER: u64 = 9;

    public fun initialize<T>(account: &signer) {
        Timestamp::assert_genesis();
        SystemAddresses::assert_core_resource(account);

        assert!(
            !exists<ValidatorOperatorConfigChainMarker<T>>(@CoreResources),
            Errors::already_published(ECHAIN_MARKER)
        );
        move_to(account, ValidatorOperatorConfigChainMarker<T>{});
    }

    public fun publish<T>(
        validator_operator_account: &signer,
        human_name: vector<u8>,
        _cap: Cap<T>
    ) {
        Timestamp::assert_operating();
        assert!(
            exists<ValidatorOperatorConfigChainMarker<T>>(@CoreResources),
            Errors::not_published(ECHAIN_MARKER)
        );

        assert!(
            !has_validator_operator_config(Signer::address_of(validator_operator_account)),
            Errors::already_published(EVALIDATOR_OPERATOR_CONFIG)
        );

        move_to(validator_operator_account, ValidatorOperatorConfig {
            human_name,
        });
    }

    /// Get validator's account human name
    /// Aborts if there is no ValidatorOperatorConfig resource
    public fun get_human_name(validator_operator_addr: address): vector<u8> acquires ValidatorOperatorConfig {
        assert!(has_validator_operator_config(validator_operator_addr), Errors::not_published(EVALIDATOR_OPERATOR_CONFIG));
        *&borrow_global<ValidatorOperatorConfig>(validator_operator_addr).human_name
    }

    public fun has_validator_operator_config(validator_operator_addr: address): bool {
        exists<ValidatorOperatorConfig>(validator_operator_addr)
    }
}

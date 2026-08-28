# 닌자소울 wallet·보스 ledger·한 번의 checkpoint retry 규칙을 검증한다.
extends GutTest

const WALLET_PATH := "res://scripts/core/ninja_soul_wallet.gd"
const LEDGER_PATH := "res://scripts/core/run_settlement_ledger.gd"
const CHECKPOINT_PATH := "res://scripts/core/run_checkpoint.gd"

var _wallet_storage_path := "user://gut_ninja_soul_wallet_retry.json"


func before_each() -> void:
	_remove_wallet_storage()


func after_each() -> void:
	_remove_wallet_storage()


func test_wallet_is_the_only_persistent_debit_owner_and_reloads_a_successful_retry_spend() -> void:
	var wallet = load(WALLET_PATH).new()
	add_child_autofree(wallet)
	assert_true(wallet.configure(_wallet_storage_path, 2))
	assert_eq(wallet.balance(), 2)
	assert_true(wallet.spend_for_retry())
	assert_eq(wallet.balance(), 1)
	var reloaded = load(WALLET_PATH).new()
	add_child_autofree(reloaded)
	assert_true(reloaded.configure(_wallet_storage_path))
	assert_eq(reloaded.balance(), 1)
	assert_false(reloaded.spend(2))
	assert_eq(reloaded.balance(), 1)


func test_boss_ledger_is_idempotent_and_checkpoint_allows_only_one_retry_for_its_active_school() -> void:
	var ledger = load(LEDGER_PATH).new()
	assert_true(ledger.record_school_boss(&"cheonsul"))
	assert_false(ledger.record_school_boss(&"cheonsul"))
	assert_true(ledger.record_school_boss(&"bongma"))
	assert_eq(ledger.eligible_school_boss_ids(), [&"cheonsul", &"bongma"])

	var checkpoint = load(CHECKPOINT_PATH).new()
	assert_true(checkpoint.capture({"gold": 17}, {"active_school_id": &"guiin"}, ledger.get_snapshot()))
	assert_true(checkpoint.can_retry_school(&"guiin"))
	assert_false(checkpoint.can_retry_school(&"bongma"))
	assert_true(checkpoint.consume_retry())
	assert_false(checkpoint.can_retry_school(&"guiin"))
	assert_false(checkpoint.consume_retry())
	assert_eq(checkpoint.get_snapshot().get("eligible_school_boss_ids"), [&"cheonsul", &"bongma"])


func _remove_wallet_storage() -> void:
	var absolute_path := ProjectSettings.globalize_path(_wallet_storage_path)
	if FileAccess.file_exists(_wallet_storage_path):
		DirAccess.remove_absolute(absolute_path)

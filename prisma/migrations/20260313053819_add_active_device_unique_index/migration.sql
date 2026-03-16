-- Enforce one active row per (license, device)
CREATE UNIQUE INDEX "license_activations_license_id_device_id_hash_active_uniq"
ON "license_activations" ("license_id", "device_id_hash")
WHERE "deactivated_at" IS NULL;

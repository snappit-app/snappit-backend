-- CreateEnum
CREATE TYPE "LicenseStatus" AS ENUM ('active', 'revoked', 'refunded');

-- CreateEnum
CREATE TYPE "WebhookEventStatus" AS ENUM ('pending', 'processing', 'processed', 'failed', 'ignored');

-- CreateEnum
CREATE TYPE "EmailJobStatus" AS ENUM ('pending', 'processing', 'sent', 'failed');

-- CreateTable
CREATE TABLE "licenses" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "activation_code_hash" TEXT NOT NULL,
    "activation_code_last4" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "status" "LicenseStatus" NOT NULL DEFAULT 'active',
    "max_devices" INTEGER NOT NULL DEFAULT 2,
    "paddle_transaction_id" TEXT NOT NULL,
    "paddle_customer_id" TEXT,
    "last_event_occurred_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "licenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "license_activations" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "license_id" UUID NOT NULL,
    "device_id_hash" TEXT NOT NULL,
    "device_name" TEXT,
    "platform" TEXT,
    "app_version" TEXT,
    "activated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deactivated_at" TIMESTAMPTZ(6),

    CONSTRAINT "license_activations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_events" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "event_id" TEXT NOT NULL,
    "notification_id" TEXT,
    "event_type" TEXT NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "status" "WebhookEventStatus" NOT NULL DEFAULT 'pending',
    "payload" JSONB NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "next_retry_at" TIMESTAMPTZ(6),
    "error_message" TEXT,
    "processed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "webhook_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "email_jobs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "template" TEXT NOT NULL,
    "to_email" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" "EmailJobStatus" NOT NULL DEFAULT 'pending',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "next_retry_at" TIMESTAMPTZ(6),
    "error_message" TEXT,
    "sent_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "email_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "action" TEXT NOT NULL,
    "license_id" UUID,
    "metadata" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "licenses_activation_code_hash_key" ON "licenses"("activation_code_hash");

-- CreateIndex
CREATE UNIQUE INDEX "licenses_paddle_transaction_id_key" ON "licenses"("paddle_transaction_id");

-- CreateIndex
CREATE INDEX "licenses_email_idx" ON "licenses"("email");

-- CreateIndex
CREATE INDEX "licenses_status_idx" ON "licenses"("status");

-- CreateIndex
CREATE INDEX "licenses_paddle_customer_id_idx" ON "licenses"("paddle_customer_id");

-- CreateIndex
CREATE INDEX "license_activations_license_id_idx" ON "license_activations"("license_id");

-- CreateIndex
CREATE INDEX "license_activations_license_id_deactivated_at_idx" ON "license_activations"("license_id", "deactivated_at");

-- CreateIndex
CREATE INDEX "license_activations_device_id_hash_idx" ON "license_activations"("device_id_hash");

-- CreateIndex
CREATE UNIQUE INDEX "webhook_events_event_id_key" ON "webhook_events"("event_id");

-- CreateIndex
CREATE INDEX "webhook_events_status_next_retry_at_idx" ON "webhook_events"("status", "next_retry_at");

-- CreateIndex
CREATE INDEX "webhook_events_event_type_idx" ON "webhook_events"("event_type");

-- CreateIndex
CREATE INDEX "email_jobs_status_next_retry_at_idx" ON "email_jobs"("status", "next_retry_at");

-- CreateIndex
CREATE INDEX "email_jobs_to_email_idx" ON "email_jobs"("to_email");

-- CreateIndex
CREATE INDEX "audit_logs_license_id_idx" ON "audit_logs"("license_id");

-- CreateIndex
CREATE INDEX "audit_logs_action_idx" ON "audit_logs"("action");

-- AddForeignKey
ALTER TABLE "license_activations" ADD CONSTRAINT "license_activations_license_id_fkey" FOREIGN KEY ("license_id") REFERENCES "licenses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_license_id_fkey" FOREIGN KEY ("license_id") REFERENCES "licenses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

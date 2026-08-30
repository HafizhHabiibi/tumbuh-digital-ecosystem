import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

const schema = fs.readFileSync(
    new URL("../src/database/schema.sql", import.meta.url),
    "utf8",
);

const getTableDefinition = (tableName) => {
    const pattern = new RegExp(
        `CREATE TABLE IF NOT EXISTS ${tableName} \\(([\\s\\S]*?)\\) ENGINE=InnoDB`,
    );
    return schema.match(pattern)?.[1] || "";
};

test("schema tetap sederhana dengan total 14 tabel", () => {
    const tableNames = [
        ...schema.matchAll(/CREATE TABLE IF NOT EXISTS\s+([a-z_]+)/g),
    ].map((match) => match[1]);

    assert.equal(tableNames.length, 14);
    assert.ok(tableNames.includes("chat_messages"));
    assert.ok(!tableNames.includes("chat_sessions"));
    assert.ok(!tableNames.includes("ai_insights"));
});

test("pengukuran memiliki metadata antrean insight yang dapat dipulihkan", () => {
    const definition = getTableDefinition("pengukuran");

    assert.match(
        definition,
        /insight_status ENUM\('pending', 'processing', 'completed', 'failed'\)/,
    );
    assert.match(definition, /insight_attempts TINYINT UNSIGNED/);
    assert.match(definition, /insight_available_at DATETIME/);
    assert.match(definition, /insight_generated_at DATETIME/);
    assert.match(definition, /insight_model VARCHAR\(100\)/);
    assert.match(definition, /insight_last_error VARCHAR\(500\)/);
    assert.match(
        definition,
        /INDEX idx_pengukuran_insight_queue \(insight_status, insight_available_at\)/,
    );
});

test("chat_messages terikat langsung ke pengukuran tanpa denormalisasi", () => {
    const definition = getTableDefinition("chat_messages");

    assert.match(definition, /pengukuran_id INT NOT NULL/);
    assert.match(
        definition,
        /FOREIGN KEY \(pengukuran_id\) REFERENCES pengukuran\(id\) ON DELETE CASCADE/,
    );
    assert.match(
        definition,
        /INDEX idx_chat_messages_history \(pengukuran_id, created_at, id\)/,
    );
    assert.doesNotMatch(definition, /\banak_id\b/);
    assert.doesNotMatch(definition, /\borang_tua_id\b/);
    assert.doesNotMatch(definition, /\bzscore_/);
    assert.doesNotMatch(definition, /\bstatus_bbu\b|\bstatus_tbu\b/);
});

test("metadata pesan membedakan input orang tua dan keluaran assistant", () => {
    const definition = getTableDefinition("chat_messages");

    assert.match(definition, /client_message_id CHAR\(36\) DEFAULT NULL/);
    assert.match(
        definition,
        /UNIQUE KEY unique_chat_client_message \(client_message_id\)/,
    );
    assert.match(
        definition,
        /FOREIGN KEY \(reply_to_message_id\) REFERENCES chat_messages\(id\) ON DELETE CASCADE/,
    );
    assert.match(definition, /UNIQUE KEY unique_chat_reply \(reply_to_message_id\)/);
    assert.match(
        definition,
        /request_status ENUM\('processing', 'completed'\)/,
    );
    assert.match(definition, /request_token CHAR\(36\)/);
    assert.match(definition, /request_expires_at DATETIME/);
    assert.match(
        definition,
        /INDEX idx_chat_request_lease \(request_status, request_expires_at\)/,
    );
    assert.match(definition, /role ENUM\('orang_tua', 'assistant'\) NOT NULL/);
    assert.match(
        definition,
        /'answered',[\s\S]*'out_of_scope',[\s\S]*'medical_advice_refused'/,
    );
    assert.match(definition, /CONSTRAINT chk_chat_message_metadata CHECK/);
    assert.match(definition, /role = 'assistant'.*reply_to_message_id IS NOT NULL/s);
});

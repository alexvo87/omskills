# Skill `postgres`: nguồn gốc và cách cập nhật

Skill này gộp hai skill upstream theo giấy phép MIT thành một skill Postgres trung lập,
không gắn với nhà cung cấp nào. Các file trong `references/` được sao chép nguyên vẹn từng
byte. Chỉ `SKILL.md` và `README.md` là viết riêng cho repo này.

## 1. Hai nguồn upstream

| Nguồn | Repo | Đường dẫn trong repo | Phiên bản | Commit đã lấy | Ngày lấy | License |
|-------|------|----------------------|-----------|---------------|----------|---------|
| Supabase | https://github.com/supabase/agent-skills | `skills/supabase-postgres-best-practices/` | 1.1.1 | `8331f910845103c08d51f6ca1d86ebb7d1f745e3` | 2026-09-24 | `LICENSE-supabase` |
| PlanetScale | https://github.com/planetscale/database-skills | `skills/postgres/` | 1.0.0 | `73b20b7eb64716d8c7100c054f0677c0c6e77e30` | 2026-09-24 | `LICENSE-planetscale` |

### Lấy gì từ Supabase

Toàn bộ 31 file trong `references/` có tên không bắt đầu bằng `_`, giữ nguyên tên. Đây là
các nhóm `query-`, `conn-`, `security-`, `schema-`, `lock-`, `data-`, `monitor-`, `advanced-`.

Không lấy:

- `SKILL.md`: thay bằng bản viết riêng.
- `CHANGELOG.md`, `references/_contributing.md`, `references/_sections.md`,
  `references/_template.md`: tài liệu nội bộ cho người đóng góp vào repo upstream.

### Lấy gì từ PlanetScale

12 file dưới đây, đổi tên thêm tiền tố `ops-`. Tiền tố giúp nhóm vận hành tách khỏi nhóm
quy tắc và không nằm lẫn với file cùng chủ đề (`partitioning.md` cạnh
`schema-partitioning.md`, `monitoring.md` cạnh nhóm `monitor-*`).

| File upstream | File trong skill |
|---------------|------------------|
| `backup-recovery.md` | `ops-backup-recovery.md` |
| `index-optimization.md` | `ops-index-optimization.md` |
| `memory-management-ops.md` | `ops-memory-management-ops.md` |
| `monitoring.md` | `ops-monitoring.md` |
| `mvcc-transactions.md` | `ops-mvcc-transactions.md` |
| `mvcc-vacuum.md` | `ops-mvcc-vacuum.md` |
| `partitioning.md` | `ops-partitioning.md` |
| `pgbouncer-configuration.md` | `ops-pgbouncer-configuration.md` |
| `process-architecture.md` | `ops-process-architecture.md` |
| `replication.md` | `ops-replication.md` |
| `storage-layout.md` | `ops-storage-layout.md` |
| `wal-operations.md` | `ops-wal-operations.md` |

Không lấy, kèm lý do:

- `SKILL.md`: có đoạn khuyến nghị hosting của PlanetScale và link tuyệt đối. Thay bằng bản viết riêng.
- `schema-design.md`, `indexing.md`, `query-patterns.md`: trùng với bộ quy tắc Supabase vốn
  viết kỹ hơn. `schema-design.md` còn khuyên đặt tên bảng số ít như `user`, `order`, là từ
  khóa dành riêng của Postgres.
- `optimization-checklist.md`: đã gộp ý vào mục "Optimization checklist" của `SKILL.md`.
- `ps-cli-api-insights.md`, `ps-cli-commands.md`, `ps-connection-pooling.md`,
  `ps-connections.md`, `ps-extensions.md`, `ps-insights.md`: chỉ dùng cho nền tảng và CLI
  của PlanetScale.

### Khác biệt so với upstream cần nhớ

- Hai file `security-rls-*` của Supabase dùng `auth.uid()`. Hàm này không có trên Postgres
  thường. `SKILL.md` có mục hướng dẫn thay bằng `current_setting` đặt qua `SET LOCAL`.
- Cuối nhiều file quy tắc Supabase có một dòng link tới `supabase.com/docs`. Giữ nguyên để
  diff với upstream không bị nhiễu.

## 2. Quy trình cập nhật từ upstream

Nguyên tắc: không sửa tay file trong `references/`. Mọi thay đổi nội dung đến từ upstream
qua quy trình dưới đây, để lần sau vẫn diff được. Nếu thật sự cần sửa một file, tách phần
sửa thành file mới với tên riêng và ghi vào mục 1.

### Bước 1. Clone hai nguồn vào thư mục tạm

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/supabase/agent-skills.git "$TMP/supabase"
git -C "$TMP/supabase" sparse-checkout set skills/supabase-postgres-best-practices
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/planetscale/database-skills.git "$TMP/planetscale"
git -C "$TMP/planetscale" sparse-checkout set skills/postgres

SUP="$TMP/supabase/skills/supabase-postgres-best-practices"
PSC="$TMP/planetscale/skills/postgres"
echo "supabase    $(git -C "$TMP/supabase" rev-parse HEAD)"
echo "planetscale $(git -C "$TMP/planetscale" rev-parse HEAD)"
```

Ghi lại hai commit SHA in ra. Nếu SHA trùng với bảng ở mục 1 thì upstream chưa đổi, dừng ở đây.

### Bước 2. Xem có gì thay đổi

Chạy từ thư mục `skills/postgres/`. Lệnh in ra ba loại kết quả: file đã đổi nội dung,
file upstream mới thêm mà skill chưa có, và file skill đang có mà upstream đã xóa.

```bash
cd skills/postgres

echo "== Supabase: file đã đổi nội dung =="
for f in references/[!o]*.md; do
  b=$(basename "$f"); [ -f "$SUP/references/$b" ] && ! cmp -s "$SUP/references/$b" "$f" && echo "  $b"
done
echo "== Supabase: file mới ở upstream =="
for f in "$SUP"/references/*.md; do
  b=$(basename "$f"); case "$b" in _*) continue;; esac; [ -f "references/$b" ] || echo "  $b"
done
echo "== Supabase: file upstream đã xóa =="
for f in references/[!o]*.md; do
  b=$(basename "$f"); [ -f "$SUP/references/$b" ] || echo "  $b"
done

echo "== PlanetScale: file đã đổi nội dung =="
for f in references/ops-*.md; do
  b=$(basename "$f"); u="${b#ops-}"; [ -f "$PSC/references/$u" ] && ! cmp -s "$PSC/references/$u" "$f" && echo "  $b"
done
echo "== PlanetScale: file mới ở upstream (chưa quyết định lấy hay bỏ) =="
for f in "$PSC"/references/*.md; do
  b=$(basename "$f"); [ -f "references/ops-$b" ] || echo "  $b"
done
echo "== PlanetScale: file upstream đã xóa =="
for f in references/ops-*.md; do
  b=$(basename "$f"); [ -f "$PSC/references/${b#ops-}" ] || echo "  $b"
done
```

Với file đã đổi nội dung, xem diff cụ thể trước khi lấy:

```bash
diff "$SUP/references/<tên>.md" references/<tên>.md
diff "$PSC/references/<tên>.md" references/ops-<tên>.md
```

Lưu ý danh sách "file mới ở upstream" của PlanetScale sẽ luôn liệt kê các file đã cố ý bỏ
ở mục 1 (`schema-design.md`, `indexing.md`, `query-patterns.md`, `optimization-checklist.md`,
`ps-*.md`). Chỉ quan tâm tên nào không có trong danh sách bỏ đó.

### Bước 3. Áp dụng

Chép đè file đã đổi. Với file mới, quyết định lấy hay bỏ rồi ghi vào mục 1.

```bash
# Supabase: chép đè toàn bộ file quy tắc (bỏ qua file bắt đầu bằng _)
for f in "$SUP"/references/*.md; do
  b=$(basename "$f"); case "$b" in _*) continue;; esac; cp "$f" "references/$b"
done

# PlanetScale: chỉ chép 12 file đã chọn, thêm tiền tố ops-
for n in backup-recovery index-optimization memory-management-ops monitoring \
         mvcc-transactions mvcc-vacuum partitioning pgbouncer-configuration \
         process-architecture replication storage-layout wal-operations; do
  cp "$PSC/references/$n.md" "references/ops-$n.md"
done

# License
cp "$TMP/supabase/LICENSE" LICENSE-supabase
cp "$TMP/planetscale/LICENSE" LICENSE-planetscale
```

Nếu upstream thêm file mới mà bạn quyết định lấy: chép vào `references/` (thêm `ops-` nếu
từ PlanetScale), thêm một dòng vào bảng chỉ mục tương ứng trong `SKILL.md`, và cập nhật mục 1.
Nếu upstream xóa file: xóa file đó trong `references/`, xóa dòng trong `SKILL.md`, ghi vào mục 1.

### Bước 4. Kiểm tra sau khi cập nhật

```bash
cd skills/postgres

# 43 file, trong đó 12 file ops- (sửa con số nếu mục 1 đã thay đổi)
ls references | wc -l; ls references/ops-* | wc -l

# Mọi link trong SKILL.md đều trỏ tới file tồn tại
for l in $(grep -o 'references/[a-z0-9-]*\.md' SKILL.md | sort -u); do [ -f "$l" ] || echo "THIẾU: $l"; done

# Mọi file trong references đều được SKILL.md link tới
for f in references/*.md; do grep -q "($f)" SKILL.md || echo "CHƯA LINK: $f"; done

# Không lọt chuỗi quảng cáo nhà cung cấp
grep -rIl 'planetscale.com\|pscale\|best place to host' . --exclude=LICENSE-planetscale --exclude=README.md || echo "sạch"

# Xem upstream có đổi mô tả hoặc phiên bản trong SKILL.md của họ không, để cân nhắc cập nhật SKILL.md của mình
grep -m1 '^  version:' "$SUP/SKILL.md"; grep -m1 '^  version:' "$PSC/SKILL.md"
```

### Bước 5. Ghi lại

- Cập nhật cột "Phiên bản", "Commit đã lấy", "Ngày lấy" trong bảng ở mục 1.
- Nếu tập file lấy hoặc bỏ thay đổi, sửa các danh sách ở mục 1 cho khớp.
- Xóa thư mục tạm: `rm -rf "$TMP"`.

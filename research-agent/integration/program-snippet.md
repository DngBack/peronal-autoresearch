# Đoạn chèn vào program.md (Research Agent mode)

Chép nội dung dưới đây vào **đầu** file `program.md` của repo thí nghiệm (hoặc vị trí phù hợp), để agent biết dùng research_brief và các Cursor skills.

---

## Research Agent mode (mục tiêu do người dùng nhập)

Khi user muốn research theo **mục tiêu** (giả thuyết / paper / bảng so sánh + draft paper):

1. **Đầu vào:** User điền `research_brief.md` (mục tiêu, time budget, success criteria, gợi ý đọc thêm). Spec đầy đủ: `specs/research-agent-spec.md`.
2. **Workflow:** Dùng các Cursor skills trong `.cursor/skills/`:
   - **research-setup:** Đọc repo + research_brief → tạo `research_plan.md` (mục tiêu, danh sách thí nghiệm).
   - **research-experiment:** Chọn thí nghiệm → sửa code (có thể nhiều file) → chạy `uv run train.py` → ghi results.tsv + cập nhật plan → keep/discard. Lặp.
   - **research-synthesis:** Khi đủ thí nghiệm → tổng hợp **bảng so sánh** → viết/cập nhật `draft/paper.md`.
   - **research-read-external:** Khi cần, đọc URL/papers để cải thiện ý tưởng.
3. **Artifacts:** research_plan.md, results.tsv, bảng so sánh (trong plan hoặc draft/), draft/paper.md.
4. **Bắt đầu:** User có thể nói "đọc research_brief và bắt đầu research" → agent dùng research-setup rồi vào vòng research-experiment.

Phần dưới mô tả chế độ experiment gốc của repo (vd tối ưu metric, chỉ sửa train.py).

---

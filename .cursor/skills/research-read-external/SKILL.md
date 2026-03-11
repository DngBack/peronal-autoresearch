---
name: research-read-external
description: Khi cần, fetch hoặc đọc tài liệu bên ngoài (URL, paper, blog) để cải thiện ý tưởng hoặc thiết kế thí nghiệm. Dùng trong research-setup hoặc giữa vòng experiment khi cần tham khảo.
---

# Research Read External

Dùng skill này khi agent **cần đọc thêm** tài liệu bên ngoài repo (paper, blog, URL) để:
- Hiểu related work hoặc baseline.
- Lấy ý tưởng cho thí nghiệm (trick, kiến trúc, hyperparameter).
- Làm rõ giả thuyết hoặc metric.

Nguồn có thể do user ghi trong `research_brief.md` (mục "Gợi ý đọc thêm") hoặc agent tự chọn khi thấy thiếu context.

## Khi nào dùng

- research_brief có mục "Gợi ý đọc thêm" với URL hoặc tên tài liệu.
- Trong research-setup: trước khi viết research_plan, cần nắm related work.
- Trong research-experiment: kẹt ý tưởng, muốn tham khảo paper/blog trước khi đề xuất thí nghiệm mới.
- User nói "đọc link này và dùng cho research", "thêm related work từ URL X".

## Instructions

1. **Xác định nguồn**
   - Ưu tiên: list URL/tài liệu trong research_brief (mục 4).
   - Nếu không có: agent có thể đề xuất 1–2 nguồn liên quan trực tiếp đến mục tiêu (vd arxiv, blog, repo); tránh đọc tràn lan.
   - Giới hạn: ít nguồn (vd 1–3), hoặc giới hạn độ dài (vd tóm tắt 1–2 trang tương đương) để không làm lạc đề.

2. **Lấy nội dung**
   - **URL (web, arxiv abstract/html):** Dùng tool fetch URL (nếu có) hoặc mcp_web_fetch để lấy nội dung dạng text/markdown.
   - **PDF:** Nếu chỉ có link PDF, fetch nếu tool hỗ trợ; nếu không thì ghi lại link và tóm tắt theo abstract/title, hoặc báo user "cần copy-paste đoạn quan trọng".
   - **File trong repo:** Đọc trực tiếp (vd `docs/xyz.md`, `papers/notes.md`).

3. **Tóm tắt và gắn với research**
   - Tóm tắt ngắn: ý chính, phương pháp/baseline liên quan, số liệu nổi bật (nếu có).
   - Gắn với mục tiêu hiện tại: "Ý này có thể dùng cho thí nghiệm X" hoặc "Baseline này tương tự với ...".
   - Ghi vào research_plan (phần "Related work / Đọc thêm") hoặc chỉ dùng trong context bước tiếp (setup/experiment) mà không cần lưu dài.

4. **Ràng buộc**
   - Ưu tiên nguồn **trực tiếp** liên quan đến mục tiêu; tránh đọc quá nhiều.
   - Nếu không fetch được (paywall, lỗi): ghi lại URL và nhận định "chưa đọc được"; có thể bỏ qua hoặc nhờ user cung cấp đoạn trích.

## Output

- Tóm tắt ngắn (vài câu đến một đoạn) cho mỗi nguồn đã đọc.
- (Tùy chọn) Cập nhật research_plan.md: thêm mục "Related work / Đọc thêm" với tóm tắt và link.
- Gợi ý áp dụng: "Có thể thử X trong thí nghiệm tiếp" hoặc "Baseline Y tương tự, ta so sánh với Z."

## Lưu ý

- Skill này **bổ trợ** research-setup và research-experiment; không thay thế việc đọc repo (prepare.py, train.py, spec).
- Nếu Cursor không có tool fetch URL, agent có thể hướng dẫn user paste nội dung quan trọng vào research_brief hoặc file trong repo, rồi đọc từ đó.

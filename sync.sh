#!/bin/bash
# 家庭教育知识库 → GitHub Pages 同步脚本
# 用法: ./sync.sh [commit_message]
# 示例: ./sync.sh "新增第30节摘要"

QUARTZ_DIR="/Users/ylf/Software/quartz"
WIKI_SOURCE="/Users/ylf/知识库/家庭教育/家庭教育/wiki"

cd "$QUARTZ_DIR" || exit 1

echo "=== 1. 同步 Wiki 内容到 Quartz ==="
# 清空旧内容（保留目录结构）
rm -rf content/concepts content/summaries content/entities content/comparisons content/overviews content/synthesis content/topics
# 复制最新内容
cp -R "$WIKI_SOURCE/"* content/
# 删除不需要的文件
rm -f content/.gitkeep
echo "内容已同步"

echo "=== 2. 修复 frontmatter 双引号问题 ==="
# 将标题中的 ASCII 双引号替换为中文角引号，避免 YAML 解析错误
node -e '
const fs = require("fs");
const path = require("path");
function walkDir(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walkDir(full);
    else if (entry.name.endsWith(".md")) fixFile(full);
  }
}
function fixFile(f) {
  let lines = fs.readFileSync(f, "utf8").split("\n");
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].startsWith("title: ")) {
      let rest = lines[i].substring(7);
      if (rest.startsWith("\"") && rest.endsWith("\"")) {
        let inner = rest.substring(1, rest.length - 1);
        let count = 0, fixed = "";
        for (const ch of inner) {
          if (ch === "\"") { count++; fixed += (count % 2 === 1) ? "\u300c" : "\u300d"; }
          else fixed += ch;
        }
        lines[i] = "title: \"" + fixed + "\"";
      }
      break;
    }
  }
  fs.writeFileSync(f, lines.join("\n"), "utf8");
}
walkDir("content");
console.log("frontmatter 修复完成");
'
echo "双引号修复完成"

echo "=== 3. 提交并推送到 GitHub ==="
git add -A
MSG="${1:-update: 同步知识库更新}"
git commit -m "$MSG"
git push origin main
echo "推送完成！"

echo ""
echo "=== 完成 ==="
echo "网站将在 2-3 分钟后自动更新"
echo "访问地址: https://hi-ylf.github.io/family_education/"
echo ""
echo "如需本地预览，运行: ./start.sh"

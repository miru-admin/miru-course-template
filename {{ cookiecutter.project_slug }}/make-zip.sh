#!/bin/bash
# ==============================================================================
# MiruApp実験管理コンソールへアップするためのZIPファイルを作成するスクリプト
# 作成されたZIPの名前を変更すると、アプリ上で動作しなくなる場合があります
# （ZIPファイルの名前のうち"__"より前とディレクトリの名前が一致している必要があるためです）。
# 作成されるZIPファイルの名前とディレクトリの名前を別にしたい場合は、--nameオプションを使ってください。
# 使い方：
#   ./script.sh                          -> <現在のフォルダ名>.zip
#   ./script.sh --name test              -> test.zip (解凍後フォルダ名: test)
#   ./script.sh v1.0                     -> <現在のフォルダ名>__v1.0.zip
#   ./script.sh --name test v1.0         -> test__v1.0.zip
# ==============================================================================

CUSTOM_NAME=""
SUFFIX=""

while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      CUSTOM_NAME="$2"
      shift 2
      ;;
    *)
      SUFFIX="$1"
      shift
      ;;
  esac
done

# 現在のディレクトリ名を取得
DIR_NAME=$(basename "$(pwd)")

# ベースとなる名前の決定（--name が指定されていればそれを優先）
if [ -n "$CUSTOM_NAME" ]; then
  BASE_NAME="$CUSTOM_NAME"
else
  BASE_NAME="$DIR_NAME"
fi

# サフィックスの有無に応じた最終的な名称を設定
if [ -n "$SUFFIX" ]; then
  NEW_DIR_NAME="${BASE_NAME}__${SUFFIX}"
else
  NEW_DIR_NAME="${BASE_NAME}"
fi

# 親ディレクトリへ移動
cd ..

# 元のディレクトリ名と圧縮時の名前が異なる場合、一時的にシンボリックリンクを作成
IS_LINK=0
if [ "$NEW_DIR_NAME" != "$DIR_NAME" ]; then
  rm -f "$NEW_DIR_NAME"
  ln -s "$DIR_NAME" "$NEW_DIR_NAME"
  IS_LINK=1
fi

# 不要ファイルを除外してZIP圧縮
zip -r "${NEW_DIR_NAME}.zip" "$NEW_DIR_NAME" \
    -x "$NEW_DIR_NAME/x-*" \
    -x "$NEW_DIR_NAME/**/x-*" \
    -x "$NEW_DIR_NAME/.git/*" \
    -x "*.ai" \
    -x "*.af" \
    -x "*.zip" \
    -x "$NEW_DIR_NAME/**/._*" \
    -x "$NEW_DIR_NAME/._*" \
    -x "$NEW_DIR_NAME/.DS_Store" \
    -x "$NEW_DIR_NAME/.gitignore"

# 一時作成したシンボリックリンクを削除
if [ "$IS_LINK" -eq 1 ]; then
  rm -f "$NEW_DIR_NAME"
fi

# 生成されたZIPファイルを元のディレクトリ内に移動して復帰
mv "${NEW_DIR_NAME}.zip" "${DIR_NAME}/${NEW_DIR_NAME}.zip"
cd "${DIR_NAME}"
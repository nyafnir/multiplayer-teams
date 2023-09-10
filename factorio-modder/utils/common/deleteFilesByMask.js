import { readdirSync, unlinkSync } from "fs";

/**
 * @param {string} pathToDir
 * @param {string} mask
 * @returns {void}
 */
export function deleteFilesByMask(pathToDir, mask) {
  const files = readdirSync(pathToDir);

  const deletedFiles = files?.filter((fileName) =>
    new RegExp(mask).test(fileName)
  );

  if (!deletedFiles?.length) {
    return;
  }

  deletedFiles.forEach((fileName) => unlinkSync(`${pathToDir}\\${fileName}`));
}

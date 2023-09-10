import { getOpenProcessId } from "../common";

/**
 * @throws unknown
 * @returns {Promise<void> | never}
 */
export async function closeGame() {
  const pid = await getOpenProcessId('factorio.exe');

  if (!pid) {
    return;
  }

  process.kill(pid, "SIGKILL");
}

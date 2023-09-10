import { sleep, getOpenProcessId } from "../common";

/**
 * @returns {Promise<void>}
 */
export async function waitGameClosed() {
  while (await getOpenProcessId("factorio.exe")) {
    await sleep(1);
  }
}

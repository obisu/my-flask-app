import { api } from "../client";

export function getData() {
  return api("/api/data");
}


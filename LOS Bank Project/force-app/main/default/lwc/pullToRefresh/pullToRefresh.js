import { LightningElement } from "lwc";

export default class PullToRefresh extends LightningElement {
  connectedCallback() {
    this.disablePullToRefresh();
  }
  disablePullToRefresh() {
    const disableRefresh = new CustomEvent("updateScrollSettings", {
      detail: {
        isPullToRefreshEnabled: false
      },
      bubbles: true,
      composed: true
    });
    this.dispatchEvent(disableRefresh);
  }
}
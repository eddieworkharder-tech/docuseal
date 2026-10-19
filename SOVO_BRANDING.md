# SOVO Sign development fork

This branch is based on the official DocuSeal 3.3.1 release and adds SOVO branding, an electronic-record disclosure step, and an account-scoped contract status dashboard.

## Attribution and licensing

- The upstream `LICENSE` and `LICENSE_ADDITIONAL_TERMS` files remain unchanged.
- Keep the visible `Powered by DocuSeal` attribution on the public landing page and signer-facing interface.
- This branch does not unlock, imitate, or modify DocuSeal Pro features.
- The business dashboard uses the signed-in user's existing DocuSeal account permissions and exposes existing submission events; it does not add cross-account access or change signature records.
- The electronic-record disclosure checkbox requires an affirmative, unselected-by-default action before continuing. The disclosure text/version and acceptance timestamp are recorded by the audit trail.
- Review DocuSeal's AGPLv3 terms and additional terms before distributing a modified service or making it available over a network.

## SOVO theme

- SOVO logo: `public/sovo-logo.png`
- Primary: SOVO blue (`#3159d9`)
- Secondary: SOVO yellow (`#fec601`)
- Interface copy and colors are maintained in the Rails view partials and Tailwind theme.

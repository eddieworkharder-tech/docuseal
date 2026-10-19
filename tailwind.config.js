module.exports = {
  future: {
    hoverOnlyWhenSupported: true
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      {
        docuseal: {
          'color-scheme': 'light',
          primary: '#3159d9',
          secondary: '#fec601',
          accent: '#3159d9',
          neutral: '#1f2b4d',
          'base-100': '#ffffff',
          'base-200': '#f6f8fc',
          'base-300': '#e5eaf3',
          'base-content': '#1f2b4d',
          '--rounded-btn': '1.9rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        }
      }
    ]
  }
}

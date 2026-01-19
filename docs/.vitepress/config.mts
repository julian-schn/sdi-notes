import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "SDI Notes",
  description: "Comprehensive notes on Terraform and modern infrastructure practices",
  base: '/sdi-notes/',

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Infrastructure as Code', link: '/iac/' },
      { text: 'Exercises', link: '/exercises/' }
    ],

    sidebar: {
      '/iac/': [
        {
          text: 'Infrastructure as Code',
          items: [
            { text: 'Introduction', link: '/iac/introduction' },
            { text: 'Terraform Installation', link: '/iac/terraform-install' },
            { text: 'Terraform Basics', link: '/iac/terraform-basics' },
            { text: 'Terraform Configuration', link: '/iac/terraform-configuration' },
            { text: 'Hetzner Setup', link: '/iac/terraform-hetzner-setup' },
            { text: 'Secrets Management', link: '/iac/terraform-secrets-management' }
          ]
        }
      ],
      '/exercises/': [
        {
          text: 'Exercises',
          items: [
            {
              text: 'SSH & Networking', collapsed: false, items: [
                { text: '06 - SSH Hopping', link: '/exercises/06-ssh-hopping' },
                { text: '07 - SSH Port Forwarding', link: '/exercises/07-ssh-port-forwarding' },
                { text: '08 - X11 Forwarding', link: '/exercises/08-x11-forwarding' }
              ]
            },
            {
              text: 'System Administration', collapsed: false, items: [
                { text: '09 - Rsync', link: '/exercises/09-rsync' },
                { text: '10 - Index-based Search', link: '/exercises/10-index-based-search' },
                { text: '11 - Tail', link: '/exercises/11-tail' },
                { text: '12 - Journalctl', link: '/exercises/12-journalctl' }
              ]
            },
            {
              text: 'Infrastructure Automation', collapsed: false, items: [
                { text: '13 - Base System', link: '/exercises/13-base-system' },
                { text: '14 - Nginx Automation', link: '/exercises/14-nginx-automation' },
                { text: '15 - Cloud Init', link: '/exercises/15-cloud-init' },
                { text: '16 - SSH Known Hosts', link: '/exercises/16-ssh-known-hosts' },
                { text: '17 - Host Metadata', link: '/exercises/17-host-metadata' },
                { text: '18 - SSH Module', link: '/exercises/18-ssh-module' },
                { text: '19 - Volume (Manual)', link: '/exercises/19-volume-manual' },
                { text: '20 - Volume (Auto)', link: '/exercises/20-volume-auto' },
                { text: '21 - Enhancing Web Server', link: '/exercises/21-enhancing-web-server' },
                { text: '22 - Creating DNS Records', link: '/exercises/22-creating-dns-records' },
                { text: '23 - Host with DNS', link: '/exercises/23-host-with-dns' },
                { text: '24 - Fixed Server Count', link: '/exercises/24-multiple-servers' },
                { text: '25 - Web Certificate', link: '/exercises/25-web-certificate' },
                { text: '26 - Testing Certificate', link: '/exercises/26-testing-certificate' },
                { text: '27 - Combined Setup', link: '/exercises/27-combined-setup' }
              ]
            }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/julian-schn/sdi-notes' }
    ],

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/julian-schn/sdi-notes/edit/main/docs/:path'
    },

    lastUpdated: {
      text: 'Updated at',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'short'
      }
    }
  },


  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    },
    lineNumbers: true
  }
})

module.exports = {
    title: 'Gerbil Scheme',
    description: '',
    themeConfig: {
        nav: [
          { text: 'Home', link: '/' },
          { text: 'Guide', link: '/guide/' },
          { text: 'Tutorials', link: '/tutorials/' },
          { text: 'StdLib', link: '/api/' },
        ],
        sidebarDepth: 2,
        sidebar: {
          '/guide/': [
            {
              collapsable: false,
              title: 'Guide',
              children: ['', 'intro', 'shell', 'package-manager', 'ffi', 'build', 'profiler', 'srfi', 'core-prelude', 'r7rs', 'bootstrap', 'nix']
            }
          ],
          '/api/': [
            {
              collapsable: false,
              title: 'Gerbil API Reference',
              children: ['', 'actor', 'coroutine', 'crypto', 'db', 'debug', 'errors', 'events', 'format', 'generic', 'getopt', 'iterators',
              'lazy', 'logger', 'make', 'misc', 'net', 'os', 'parser', 'regexp', 'sort', 'srfi', 'stxparam', 'sugar', 'test', 'text',
              'web', 'xml']
            }
          ]
        },
        // Assumes GitHub. Can also be a full GitLab url.
        repo: 'vyzo/gerbil',
        // Customising the header label
        // Defaults to "GitHub"/"GitLab"/"Bitbucket" depending on `themeConfig.repo`
        repoLabel: 'Contribute!',

        // Optional options for generating "Edit this page" link

        // if your docs are in a different repo from your main project:
        docsRepo: 'khepin/gerbil-docs',
        // if your docs are not at the root of the repo:
        docsDir: 'docs',
        // if your docs are in a specific branch (defaults to 'master'):
        docsBranch: 'master',
        // defaults to false, set to true to enable
        editLinks: true,
        // custom text for edit link. Defaults to "Edit this page"
        editLinkText: 'Help us improve this page!',
      },
      current_version: 'v0.12'
  }
const writeBasic = """
<!doctype HTML>
<html>

<head>
  <meta charset="UTF-8">
  <meta content="True" name="HandheldFriendly">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="theme-color" content="#fff">
  <meta name="theme-color" content="#1c1c1e" media="(prefers-color-scheme: dark)">
  <title>Preview</title>
  <style>
    :root {
      --background-color: white;
      --foreground-color: #000;
      --link-color: #336bad;
      --foreground-secondary-color: #666;
      --border-color: #e2e2e2;
    }

    @media (prefers-color-scheme: dark) {
      :root {
        --background-color: black;
        --foreground-color: #fff;
        --link-color: #6699ff;
        --foreground-secondary-color: #adadaf;
        --border-color: #2b2b2d;
      }
    }

    html {
      padding: 0;
      margin: 0;
    }

    body {
      background-color: var(--background-color);
      color: var(--foreground-color);
      padding: 20px;
      margin: 0;
      font-family: helvetica neue, Arial, hiragino sans gb, microsoft yahei, sans-serif;
    }

    h1 {
      color: var(--foreground-color);
      font-size: 2em;
    }

    hr {
      border: none;
      height: 2px;
      color: var(--border-color);
      background-color: var(--border-color);
      margin-top: 1em;
      margin-bottom: 1em;
    }

    a:link,
    a:visited,
    a:active {
      color: var(--link-color);
      text-decoration: none;
      line-break: anywhere;
    }

    a:hover {
      text-decoration: underline;
    }

    code {
      line-break: anywhere;
    }

    img {
      max-width: 100%;
    }

    p {
      text-align: justify;
    }

    .date {
      font-size: 0.8em;
      color: var(--foreground-secondary-color);
    }

    .content {
      margin: -20px 0 0 0;
      line-height: 160%;
      font-size: 1em;
      color: var(--foreground-color);
    }
  </style>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      let pos = JSON.parse(localStorage.getItem('scrollpos'));
      if (pos) {
        window.scrollTo(0, pos);
      }
    });
    function scrollPosition(positionPercent) {
      window.scrollTo(0, document.body.scrollHeight * positionPercent);
      localStorage.setItem('scrollpos', JSON.stringify(window.scrollY));
    }
  </script>
</head>

<body>
  <div class="content">
    {{ content_html }}
  </div>
</body>

</html>
""";

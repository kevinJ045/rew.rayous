Svr = imp 'serve'

compileFile = (target, layouts, data) ->
  script = """
  import Page from "#{target}";
  #{layouts.map((layout, index) => "import Layout#{index} from \"#{layout}\"").join('\n')}
  const Layouts = [#{layouts.map((layout, index) => "Layout#{index}").join(',')}];

  const baseProps = {
    data: #{JSON.stringify(data)}
  };

  const buildProps = (props) => ({
    ...baseProps,
    wrap(object) { return { ...this, ...object }; },
    addArgument(...args) {
      if (!Array.isArray(baseProps.args)) baseProps.args = [];
      baseProps.args.push(...args);
      return buildProps();
    },
    add(prop, value) {
      baseProps[prop] = value;
      return buildProps();
    },
    ...props
  });

  function start() {
    const pages = window.pages || [];
    if (!window.pages) window.pages = pages;

    const buildProps = (props) => ({
      ...baseProps,
      wrap(object) { return { ...this, ...object }; },
      addArgument(...args) {
        if (!Array.isArray(baseProps.args)) baseProps.args = [];
        baseProps.args.push(...args);
        return buildProps();
      },
      add(prop, value) {
        baseProps[prop] = value;
        return buildProps();
      },
      ...props
    });

    // Set page title
    if (typeof Page.title === "string") {
      document.title = Page.title;
    } else if (typeof Page.title === "function") {
      document.title = Page.title(buildProps({ page: made }));
    }

    // Append page links
    if (Array.isArray(Page.links)) {
      Page.links.forEach((url) => {
        const link = document.createElement('link');
        if (typeof url === 'string') {
          link.rel = 'stylesheet';
          link.href = url;
        } else {
          if (url.rel) link.rel = url.rel;
          if (url.href) link.href = url.href;
        }
        document.head.appendChild(link);
      });
    }

    // Append page scripts
    if (Array.isArray(Page.scripts)) {
      Page.scripts.forEach((url) => {
        const script = document.createElement('script');
        script.src = url;
        document.head.appendChild(script);
      });
    }

    // Custom head content
    if (typeof Page.headContent === "function") {
      Page.headContent(buildProps())?.forEach((item) => {
        item?.to?.(document.head);
      });
    }

    window.loadFunction = () => {
      document.body.setAttribute('class', '');
      if (!window.after && window.loaderOn) window.loader.remove();

      // Initialize the target page component
      const page = new Page();
      if (Page.inheritState !== false && window.lastPage) {
        page._inheritState(window.lastPage);
      }
      if (Page.bodyClass) {
        document.body.setAttribute('class', Page.bodyClass);
      }


      page._beforeInit();
      page.emit('beforeInit', { component: page, props: buildProps() });
      page.initState(buildProps());
      page.emit('initState', { component: page, props: buildProps() });
      const made = page.make(buildProps({ page: null }));
      page.emit('buildStart', { widget: made, component: page, props: buildProps() });
      
      let previousBuild = made;

      // Initialize each layout component
      Layouts.reverse().forEach((Layout, index) => {
        if (typeof Layout.beforeBuildStart === "function") Layout.beforeBuildStart(buildProps());
        const layout = new Layout();
        layout._beforeInit();
        layout.emit('beforeInit', { component: layout, props: buildProps() });
        layout.initState(buildProps());
        layout.emit('initState', { component: layout, props: buildProps() });
        const made = layout.make(buildProps({ page: previousBuild }));
        previousBuild = made;
        layout.emit('buildStart', { widget: made, component: layout, props: buildProps() });

        if (index === Layouts.length - 1) {
          made.to(document.body);
          layout.afterBuild(buildProps({ page: made }), ...(Array.isArray(buildProps().args) ? buildProps().args : []));
          layout.emit('buildEnd', { widget: made, component: layout, props: buildProps() });
          pages.push(layout);
          window.lastPage = layout;
        }
      });


      if(!Layouts.length) made.to(document.body);
      page.afterBuild(buildProps({ page: made }), ...(Array.isArray(buildProps().args) ? buildProps().args : []));
      page.emit('buildEnd', { widget: made, component: page, props: buildProps() });
      pages.push(page);
      window.lastPage = page;

      if (window.after && window.loaderOn) window.loader.remove();
      window.initted = true;
    };

    window.addEventListener('load', window.loadFunction);
  }

  start();
  """
  return script

export createRouter = (root, options = {}) ->
  Svr::createFileRouter { ...options, bundlerEntry: compileFile, root: root}
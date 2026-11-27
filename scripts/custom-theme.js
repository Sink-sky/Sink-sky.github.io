'use strict';

hexo.extend.injector.register('head_end', () => {
  const urlFor = hexo.extend.helper.get('url_for').bind(hexo);
  return `<link rel="stylesheet" href="${urlFor('/css/custom.css')}">`;
});

hexo.extend.filter.register('after_generate', async () => {
  const chunks = [];
  for await (const chunk of hexo.route.get('js/navbar.js')) {
    chunks.push(chunk);
  }
  const script = Buffer.concat(chunks).toString().replace(
    ".filter(':hover')",
    ".filter((index, element) => element.matches(':hover'))"
  );
  hexo.route.set('js/navbar.js', script);
});

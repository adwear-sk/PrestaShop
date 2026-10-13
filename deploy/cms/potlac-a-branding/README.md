# CMS page: Potlač a branding

Source for the `/content/{id}-potlac-a-branding` page. The page lives in the DB
(`ps_cms_lang`) and its images in `img/cms/potlac-a-branding/` (ps-img volume on
prod), so neither ships with a deploy. Apply by hand:

```sh
# from the repo root, on the VPS side
scp -r deploy/cms/potlac-a-branding deploy@178.105.70.62:/tmp/
ssh deploy@178.105.70.62 'cd /opt/adwear && docker compose cp /tmp/potlac-a-branding app:/tmp/ \
  && docker compose exec -T app sh -c "mkdir -p img/cms/potlac-a-branding && cp /tmp/potlac-a-branding/img/*.webp img/cms/potlac-a-branding/ && chown -R www-data:www-data img/cms/potlac-a-branding" \
  && docker compose exec -T -u www-data -e SYMFONY_ENV=prod app php /tmp/potlac-a-branding/upsert.php'
```

`upsert.php` creates the page (CMS category 1, slug `potlac-a-branding`) or, if it
exists, replaces its content and meta description, then clears the Smarty cache.

Markup notes: PrestaShop's HTML purifier drops `<section>`, HTML comments and
`loading="lazy"`; use `<div>`s. Layout is Bootstrap 5 classes only (theme CSS),
icons are Material Icons ligatures. Editing in the BO WYSIWYG may reformat it.

## Images (Pexels License — free for commercial use, no attribution required)

| File | Pexels photo |
|------|--------------|
| hero-tim.webp | https://www.pexels.com/photo/group-of-people-wearing-shirts-spelled-team-7551442/ |
| sietotlac.webp | https://www.pexels.com/photo/artisan-screen-printing-process-in-action-34117503/ |
| transfer.webp | https://www.pexels.com/photo/man-screen-printing-t-shirt-in-workshop-33650424/ |
| vysivka.webp | https://www.pexels.com/photo/industrial-textile-embroidery-machine-in-action-32641537/ |
| pracovne-odevy.webp | https://www.pexels.com/photo/men-posing-while-sitting-on-gray-concrete-wall-4483612/ |
| nite.webp | https://www.pexels.com/photo/colorful-spools-on-industrial-embroidery-machine-32073509/ |

<?php
/**
 * Keeps crawlers out of the visitor statistics (ps_guest, ps_connections,
 * ps_connections_source). Core's isBot() list predates almost every crawler
 * that visits today (Amazonbot, bingbot, SemrushBot, AI crawlers...), so each
 * cookieless bot request created a guest, a connection and a source row.
 */
class Connection extends ConnectionCore
{
    /**
     * Crawlers that declare themselves. Also used by CartController to refuse
     * cart updates, so it only matches self-declared bots: a bare "bot"
     * substring would also hit phone models such as Cubot.
     */
    private const BOT_PATTERN = '/\(compatible;[^)]*(bot|crawler|spider)'
        . '|\+?https?:\/\/[^\s)]*(bot|crawler|spider)'
        . '|Amazonbot|bingbot|Applebot|DuckDuckBot|PetalBot|Bytespider|CCBot|GPTBot|ChatGPT-User|OAI-SearchBot'
        . '|ClaudeBot|Claude-User|PerplexityBot|meta-externalagent|facebookexternalhit|GoogleOther|Google-InspectionTool'
        . '|AdsBot-Google|Mediapartners-Google|Twitterbot|LinkedInBot|Slackbot|Discordbot|TelegramBot|WhatsApp'
        . '|Pinterestbot|Baiduspider|HeadlessChrome|crawler|spider'
        . '|^(curl|Wget|python-requests|Python-urllib|Go-http-client|okhttp|Scrapy|axios|node-fetch|libwww-perl|Java)\//i';

    /**
     * Scrapers that disguise themselves as long-outdated browsers (Chrome < 110,
     * Firefox < 100) or send no user agent. Statistics only: a false positive
     * here must never cost a real visitor their cart.
     */
    private const UNTRACKED_PATTERN = '/^$|Chrome\/([1-9]?\d|10\d)\.|Firefox\/([1-9]?\d)\./';

    public static function isBot()
    {
        return parent::isBot()
            || (isset($_SERVER['HTTP_USER_AGENT']) && preg_match(self::BOT_PATTERN, $_SERVER['HTTP_USER_AGENT']));
    }

    /**
     * Whether the current request should be left out of visitor statistics.
     */
    public static function isUntrackedVisitor(): bool
    {
        return static::isBot() || preg_match(self::UNTRACKED_PATTERN, $_SERVER['HTTP_USER_AGENT'] ?? '');
    }

    public static function setNewConnection($cookie)
    {
        if (static::isUntrackedVisitor()) {
            return false;
        }

        return parent::setNewConnection($cookie);
    }
}

<?php
/**
 * Adds the Slovak DIČ (tax ID) to addresses, next to the core IČO (dni) and
 * IČ DPH (vat_number). The ps_address.dic column comes from
 * deploy/sql/2026-10-09-company-fields.sql.
 */
class Address extends AddressCore
{
    /** @var string|null DIČ — Slovak tax identification number (optional) */
    public $dic;

    public function __construct($id_address = null, $id_lang = null)
    {
        self::$definition['fields']['dic'] = ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 16];

        parent::__construct($id_address, $id_lang);
    }
}

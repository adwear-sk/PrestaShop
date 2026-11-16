<?php
/**
 * Checks the format of IČO, DIČ and IČ DPH in front-office address forms (account and
 * checkout) for Slovak addresses. Done here rather than in Address::$definition so that
 * back-office and CLI saves of older addresses holding junk values keep working.
 */
class CustomerAddressFormatter extends CustomerAddressFormatterCore
{
    private const SK_CONSTRAINTS = [
        'dni' => 'isSkIco',
        'dic' => 'isSkDic',
        'vat_number' => 'isSkVatNumber',
    ];

    public function getFormat()
    {
        $format = parent::getFormat();

        if ($this->getCountry()->iso_code !== 'SK') {
            return $format;
        }

        foreach (self::SK_CONSTRAINTS as $name => $constraint) {
            if (isset($format[$name])) {
                $format[$name]->addConstraint($constraint);
            }
        }

        return $format;
    }
}

<?php
/**
 * For the full copyright and license information, please view the
 * docs/licenses/LICENSE.txt file that was distributed with this source code.
 */

declare(strict_types=1);

namespace PrestaShop\PrestaShop\Adapter\Address;

use Cache;
use Doctrine\DBAL\Connection;
use PrestaShop\PrestaShop\Core\ConstraintValidator\Constraints\CleanHtml;
use PrestaShop\PrestaShop\Core\ConstraintValidator\Constraints\TypedRegex;
use PrestaShopBundle\Service\Hook\HookEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Validator\Constraints\Length;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * Adwear: adds the Slovak DIČ (ps_address.dic, declared in override/classes/Address.php)
 * to the back-office customer address form, right after the VAT number.
 */
final class AddressDicHookSubscriber implements EventSubscriberInterface
{
    private const MAX_LENGTH = 16;

    public function __construct(
        private readonly Connection $connection,
        private readonly string $dbPrefix,
        private readonly TranslatorInterface $translator,
    ) {
    }

    public static function getSubscribedEvents(): array
    {
        // The hook dispatcher looks listeners up by lowercased hook name.
        return [
            'actioncustomeraddressformbuildermodifier' => 'addField',
            'actionaftercreatecustomeraddressformhandler' => 'saveDic',
            // Before, not after, the update: an address used by an order is saved as a new copy
            // of the database row, and the after hook only gets the old ID. Writing DIČ to the
            // row first makes both a direct update and the copy carry it.
            'actionbeforeupdatecustomeraddressformhandler' => 'saveDic',
        ];
    }

    public function addField(HookEvent $event): void
    {
        $params = $event->getHookParameters();
        /** @var FormBuilderInterface $builder */
        $builder = $params['form_builder'];

        $builder->add('dic', TextType::class, [
            'label' => $this->translator->trans('Tax ID', [], 'Admin.Orderscustomers.Feature'),
            'required' => false,
            'empty_data' => '',
            'constraints' => [
                new CleanHtml(),
                new TypedRegex(['type' => TypedRegex::TYPE_GENERIC_NAME]),
                new Length(['max' => self::MAX_LENGTH]),
            ],
        ]);

        // form_widget() renders fields in insertion order: move the ones after vat_number behind dic.
        $after = false;
        foreach (array_keys($builder->all()) as $name) {
            if ($after && $name !== 'dic') {
                $child = $builder->get($name);
                $builder->remove($name);
                $builder->add($child);
            }
            $after = $after || $name === 'vat_number';
        }

        $data = $params['data'];
        $data['dic'] = $params['id'] ? (string) $this->connection->fetchOne(
            'SELECT dic FROM ' . $this->dbPrefix . 'address WHERE id_address = ?',
            [(int) $params['id']]
        ) : '';
        $builder->setData($data);
    }

    public function saveDic(HookEvent $event): void
    {
        $params = $event->getHookParameters();
        if (empty($params['id']) || !array_key_exists('dic', $params['form_data'])) {
            return;
        }

        $this->connection->update(
            $this->dbPrefix . 'address',
            ['dic' => $params['form_data']['dic']],
            ['id_address' => (int) $params['id']]
        );
        // The form already loaded this Address, and ObjectModel caches rows per request:
        // without this, the edit handler (and its copy) would reuse the stale DIČ.
        Cache::clean('objectmodel_Address_' . (int) $params['id'] . '_*');
    }
}

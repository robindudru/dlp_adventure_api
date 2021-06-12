<?php

namespace App\DataFixtures;

use App\Entity\User;
use Doctrine\Persistence\ObjectManager;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class UserFixtures extends Fixture
{
    private $passwordHasher;

    public function __construct(UserPasswordHasherInterface $passwordHasher)
    {
        $this->passwordHasher = $passwordHasher;
    }

    public function load(ObjectManager $manager)
    {
        $user = new User();

        $user->setEmail('admin@mail.com');
        $user->setFirstName('Admin');
        $user->setRoles(['ROLE_SUPER_ADMIN']);

        $user->setPassword($this->passwordHasher->hashPassword(
            $user,
            'admin'
        ));

        $manager->persist($user);
        $manager->flush();
    }
}

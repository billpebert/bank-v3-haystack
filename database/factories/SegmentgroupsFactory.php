<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Segmentgroups;
use Faker\Generator as Faker;

$factory->define(Segmentgroups::class, function (Faker $faker) {
    return [
        'SegmentGroup' => $faker->unique()->name
    ];
});

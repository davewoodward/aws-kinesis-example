const chai = require('chai');
const POST = require('../../main/masseuse/POST.js');
const randomize = require('randomatic');

describe('The Masseusse POST Module', () => {
  const name = randomize('Aa0', 10);
  const phone = `${randomize('0', 3)}-${randomize('0', 3)}-${randomize('0', 4)}`;
  const gender = 'male';

  it('should return successfully when a valid name, address, and gender are passed.', async () => {
    let response = await POST({
      body: JSON.stringify({
        name: name,
        phone: phone,
        gender: gender
      })
    });
    console.log(JSON.stringify(response));
    chai.expect(response).to.eql({
      statusCode: 201
    });
  })
});
